public class dunningMessageController {

    public String acctId { 
        get; 
        set {
            acctId = value;
            init();
        } 
    }
    
    public Account acct { get; set; }
    public List<String> AddressParts { get; set; }
    public String primaryLanguage { get; set; }
    public String d0Text { get; set; }
    public String d1Text { get; set; }
    public String d2Text { get; set; }
    public String balancePlusZero { get; set; }
    public String balancePlusFive { get; set; }
    public String balancePlusFifty { get; set; }
    public Set<String> PhoneNumbers { get; set; }
    public Map<Integer,String> textMap { get; set; }

    public void init() {
        this.acct = [
            SELECT Id, Name, OwnerId, CustomerIdText__c, PrimaryLanguage__c, SF_BillTo_Contact__r.FirstName,
            SF_BillTo_Contact__r.Name, AccountManager__r.Name,
            SF_BillTo_Contact__r.Phone, SF_BillTo_Contact__r.Email,
            AccountManager__r.Department, AccountManager__r.Phone, AccountManager__r.Email,
            Combined_Balance__c, Dunning_0_Date__c, Dunning_1_Date__c, CurrencyIsoCode,
            LegalCompanyName__c, AddressBuilder__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingCountryCode,
            (SELECT Phone FROM Contacts WHERE Phone != null)
            FROM Account 
            WHERE Id= :acctId
            LIMIT 1
        ];
        try {
            AddressParts = (List<String>)JSON.deserialize(acct.AddressBuilder__c, List<String>.class);
        } catch(exception e){}
        balancePlusZero = acct.Combined_Balance__c.format();
        Decimal dBalancePlusFive = acct.Combined_Balance__c + 5;
        Decimal dBalancePlusFifty = acct.Combined_Balance__c + 50;
        balancePlusFive = dBalancePlusFive.format();
        balancePlusFifty = dBalancePlusFifty.format();
        if (math.mod((acct.Combined_Balance__c * 100).intValue(), 100) == 0) {
            balancePlusZero += ',00';
            balancePlusFive += ',00';
            balancePlusFifty += ',00';
        } else if (math.mod((acct.Combined_Balance__c * 100).intValue(), 10) == 0) {
            balancePlusZero += '0';
            balancePlusFive += '0';
            balancePlusFifty += '0';
        }
        setMap(acct.PrimaryLanguage__c);
        PhoneNumbers = new Set<String>();
        for (SObject so : acct.getSObjects('Contacts')) {
            PhoneNumbers.add((String)so.get('Phone'));
        }
        d0Text = textMap.get(0);
        d1Text = textMap.get(1);
        //d2Text = textMap.get(2);
        d2Text = '<p>E-Mail-Adresse: ' + acct.SF_BillTo_Contact__r.Email + '</p>';
        for (String pn : PhoneNumbers) {
            d2Text += '<p>Tel.Nr.: ' + pn + '</p>';
        }
    }
    
    public void setMap(String lang) {
        if (lang == 'English') {
            textMap = enMap();
        } else if (lang == 'French') {
            textMap = frMap();
        } else {
            textMap = deMap();
        }
    }
    
    public Map<Integer,String> deMap (){
        return new Map<Integer,String>{0 => '<p>Lieber orderbird-Kunde,</p>'
            +'<p>in der Hektik des Alltags geht das eine oder andere schon einmal unter, eine Rechnung zum Beispiel. Trotzdem würden wir uns freuen, wenn Du die ausstehenden Rechnungsbeträge so schnell wie möglich auf unser Konto überweist. Solltest Du am Lastschriftverfahren teilnehmen, bitten wir um die Überprüfung und gegebenenfalls Aktualisierung der Bankinformationen unter den Einstellungen bei my.orderbird.com.</p>'
            +'<p>Anbei erhältst Du Deinen aktuellen Kontoauszug. Wir erwarten den Ausgleich der Forderungen innerhalb der nächsten 5 Tage. Solltest Du in der Zwischenzeit bereits bezahlt haben, kannst Du diese Erinnerung ignorieren.</p>'
            +'<p>Wir sind nach § 288 BGB im Verzugsfalle berechtigt, Verzugszinsen und zudem Mahngebühren zu erheben. Wenn Deine Zahlung innerhalb der nächsten 5 Tage auf unser Konto eingeht, nehmen wir von dieser Maßnahme Abstand.</p>'
            +'<p>Sollte etwas nicht zu Deiner Zufriedenheit sein, schreib uns bitte eine E-Mail an hilfe@orderbird.com.<br/></p>'
            +'<p>Liebe Grüße von Deinem orderbird-Team</p>',    
    	1 => '<p>Lieber orderbird-Kunde,</p>'
            +'<p>leider hat unsere Zahlungserinnerung nicht zum gewünschten Erfolg geführt: Ihre Zahlung steht noch immer aus. Wir sind bereit, Ihnen eine weitere Frist von 5 Tagen für die Überweisung einzuräumen. Nach § 288 BGB sind wir berechtigt Mahngebühren zu erheben. Sollten wir keinen Zahlungseingang innerhalb der nächsten 5 Tage feststellen, werden wir diesen Fall an unseren Inkassopartner INTERWEGA Debitorenmanagement GmbH abgeben.</p>'
            +'<p>Bitte beachten Sie, dass wir Ihnen aufgrund des ausstehenden Betrages die technische Unterstützung des Kassensystems auch im Notfall vorenthalten können.</p>'
            +'<br/><table>'
            +'<tr><td>Saldo</td><td style="padding-left:1rem;text-align:right;">' + balancePlusZero + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Mahngebühren</td><td style="padding-left:1rem;text-align:right;">5,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Zahlbetrag</td><td style="padding-left:1rem;text-align:right;">' + balancePlusFive + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'</table><br/>'
            +'<p>Bitte überweisen Sie den Betrag unter Angabe der Rechnungsnummer/Kundennummer auf unser Konto bei der Deutschen Bank, IBAN: DE68 1007 0124 0112 1359 00, BIC: DEUTDEDB101. Das erspart Ihnen zusätzliche Kosten.</p>'
            +'<p>Sollte etwas nicht zu Ihrer Zufriedenheit sein, schreiben Sie uns bitte eine E-Mail an hilfe@orderbird.com.<br/></p>'
            +'<p>Liebe Grüße von Ihrem orderbird-Team</p>',
    	2 => '<p>Sehr geehrter orderbird-Kunde,</p>'
            +'<p>weder unsere Zahlungserinnerung noch unsere erste Mahnung konnten Sie zur Zahlung bewegen. Wir bedauern es sehr, dass Sie die von uns entgegengebrachte  Kulanz nicht durch Zahlung erwidern. Für den verursachten Mehraufwand erlauben wir uns, erneut Mahngebühren in Höhe von 5,- '
            + acct.CurrencyIsoCode
            +' zu berechnen. Zudem erheben wir den pauschalen Verzugsschadenersatz in Höhe von 40,- '
            + acct.CurrencyIsoCode
            +' (§ 288 (5) BGB).</p>'
            +'<br/><table>'
            +'<tr><td>Saldo</td><td style="padding-left:1rem;text-align:right;">' + balancePlusZero + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Mahngebühren</td><td style="padding-left:1rem;text-align:right;">5,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Mahngebühren</td><td style="padding-left:1rem;text-align:right;">5,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Verzugspauschale nach § 288 (5) BGB</td><td style="padding-left:1rem;text-align:right;">40,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Zahlbetrag</td><td style="padding-left:1rem;text-align:right;">' + balancePlusFifty + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'</table><br/>'
            +'<p>Bitte überweisen Sie den Rechnungsbetrag inklusive Mahngebühren und Verzugspauschale innerhalb der nächsten 5 Tage. Sollten wir nichts von Ihnen hören, sehen wir uns gezwungen, den Posten an unseren Inkasso-Partner/Anwalt abzutreten. Bedenken Sie, dass sich dieser Schritt negativ auf Ihre Kreditwürdigkeit auswirken kann. Vermeiden Sie die erheblichen juristischen und finanziellen Konsequenzen für Ihr Unternehmen. Zudem behalten wir uns vor die Geschäftsbeziehung fristlos zu beenden. Dies führt zur Sperrung Ihres my.orderbird-Kundenkontos.</p>'
            +'<p>Sollten Sie den Betrag bereits bezaht haben, können Sie das Schreiben als gegenstandslos betrachten.<br/></p>'
            +'<p>Freundliche Grüße von Ihrem orderbird-Team</p>'
        };
    }

    public Map<Integer,String> enMap (){
        return new Map<Integer,String>{0 => '<p>Dear orderbird-customer,</p>'
            +'<p>In hectic everyday life, it can always happen that something gets lost; an invoice, for instance. However, we would be delighted if you could pay the outstanding balance as soon as possible. If you take part in the SEPA debit advice procedure, we would kindly ask you to double-check your bank details in your my.orderbird.com account under settings.</p>'
            +'<p>Please find a customer account statement attached. We expect the settlement of the outstanding amount within 5 days. If you have already sent your payment, please disregard this letter.</p>'
            +'<p>According to § 288 BGB we are enabled to charge reminder fees, but we will suspend these if you pay within the stated period.</p>'
            +'<p>Please transfer the total amount with specification of your account and invoice number to our account at Deutsche Bank, IBAN DE68 1007 0124 0112 1359 00, BIC DEUTDEDB101.</p>'
            +'<p>If there is anything we can do to help you, please send an Email to hilfe@orderbird.com.<br/></p>'
            +'<p>Kind regards from your orderbird-team</p>',    
    	1 => '<p>Dear orderbird-customer,</p>'
            +'<p>Earlier, we contacted you about an outstanding balance. That balance has yet to be paid. Please react within 5 days to resolve this matter. According to § 288 BGB we are enabled to charge reminder fees. '
            +'However, if we receive your payment within 5 days we will refrain from charging the fine. Otherwise, the next correspondence you receive will be from our debt collection partners at INTERWEGA.</p>'
			+'<p>Please be aware that, due to the outstanding amount, we may refuse support even in case of emergency.</p>'
            +'<br/><table>'
            +'<tr><td>Balance</td><td style="padding-left:1rem;text-align:right;">' + balancePlusZero + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Reminder fee</td><td style="padding-left:1rem;text-align:right;">5,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Total balance</td><td style="padding-left:1rem;text-align:right;">' + balancePlusFive + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'</table><br/>'
            +'<p>Please transfer the total amount stating your account and invoice number to our account at Deutsche Bank, IBAN: DE68 1007 0124 0112 1359 00, BIC: DEUTDEDB101. This will save you trouble and spare further consequences.</p>'
            +'<p>If there is anything we can do to help you, please send an Email to hilfe@orderbird.com.<br/></p>'
            +'<p>Kind regards from your orderbird-team</p>',    
    	2 => '<p>Dear orderbird-customer,</p>'
            +'<p>Neither of our payment reminders led to the payment of your outstanding invoice. We regret that our goodwill was not answered accordingly. For the effort, we are charging a second reminder fee and a general fine of 40,- '
            + acct.CurrencyIsoCode
            +' according to § 288 (5) BGB.</p>'
            +'<br/><table>'
            +'<tr><td>Balance</td><td style="padding-left:1rem;text-align:right;">' + balancePlusZero + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Reminder fee</td><td style="padding-left:1rem;text-align:right;">5,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Reminder fee</td><td style="padding-left:1rem;text-align:right;">5,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>General fine according to § 288 (5) BGB</td><td style="padding-left:1rem;text-align:right;">40,00 ' + acct.CurrencyIsoCode + '</td></tr>'
            +'<tr><td>Total balance</td><td style="padding-left:1rem;text-align:right;">' + balancePlusFifty + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'</table><br/>'
            +'<p>We will still give you the opportunity to pay the total amount within 5 days.</p>'
            +'<p>In case of no reaction on your side, we are compelled to start an encashment process including possible court collection proceedings. This will have negative effects on your creditworthiness. In addition, we reserve the right to cancel our business relationship. This will lead to a blockage of your my.orderbird.com-account. Please avoid these final steps by paying the outstanding amount.</p>'
            +'<p>If you have already sent your payment, please disregard this letter.<br/></p>'
            +'<p>Kind regards from your orderbird-team</p>'
        };
    }

    public Map<Integer,String> frMap (){
        return new Map<Integer,String>{0 => '<p>Madame, Monsieur,</p>'
            +'<p>Sauf erreur ou omission de notre part, nous n\'avons pas enregistré le règlement de nos honoraires pour un montant restant dû dont vous trouverez le détail pièce jointe.</p>'
            +'<p>Nous vous saurions gré de bien vouloir nous faire parvenir votre règlement par tout moyen à votre convenance.</p>'
            +'<p>Si votre paiement s\'est croisé avec notre rappel, merci de ne pas tenir compte de cette relance.</p>'
            +'<p>Dans cette attente, nous vous prions d\'agréer, Madame, Monsieur, l\'expression de nos salutations distinguées.</p>'
            +'<p>Pour toute question, merci de nous envoyer un e-mail à assistance@orderbird.com<br/></p>'
            +'<p>La comptabilité</p>',    
    	1 => '<p>Madame, Monsieur,</p>'
            +'<p>Vous n\'avez pas donné suite à notre première relance, et nous n\'avons toujours pas enregistré le règlement de nos honoraires pour un montant restant dûdont.</p>'
			+'<p>Veuillez noter qu\'en raison du montant impayé, nous pouvons vous refuser l\'accès à l\'assistance même en cas d\'urgence.</p>'
            +'<br/><table>'
            +'<tr><td>Solde</td><td style="padding-left:1rem;text-align:right;">' + balancePlusZero + ' ' + acct.CurrencyIsoCode + '</td></tr>'
            +'</table><br/>'
            +'<p>Nous vous saurions gré de bien vouloir nous faire parvenir votre règlement par tout moyen à votre convenance afin de continuer à bénéficier de l\'ensemble de nos services.</p>'
            +'<p>Dans cette attente, nous vous prions d\'agréer, Madame, Monsieur, l\'expression de nos salutations distinguées.<br/></p>'
            +'<p>La comptabilité</p>',    
    	2 => '<p>Madame, Monsieur,</p>'
            +'<p>Vous n\'avez pas donné suite à nos relances, et votre compte présente toujours un solde en notre faveur.</p>'
            +'<p>Compte tenu de l\'ancienneté de cette créance, et afin de continuer à bénéficier de l\'ensemble de nos services, nous vous saurions gré de bien vouloir régulariser votre situation par retour de courrier.</p>'
            +'<p>Dans cette attente, nous vous prions d\'agréer, Madame, Monsieur, l\'expression de nos salutations distinguées.<br/></p>'
            +'<p>La comptabilité</p>'
    	};
    }



}