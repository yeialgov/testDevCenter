public class KpiController {
    
    public class JsonStepper {
        public Map<String, Object> m { get; set; }
        public JsonStepper(Map<String, Object> inputMap) {
            m = inputMap;
        }
        public JsonStepper x(String s) {
            return new JsonStepper((Map<String, Object>)m.get(s));
        }
    }
    
    public JsonStepper j = new JsonStepper((Map<String, Object>)JSON.deserializeUntyped([SELECT Body FROM StaticResource where name = 'InsightsStrings' limit 1].body.tostring()));

    public String YeDayNum = String.valueOf(Math.mod(Date.newInstance(1900, 1, 7).daysBetween(Date.today().addDays(-1)),7));
    
    public Map<String, Object> process(InsightsSender.SectionWrapper SW) {
        Map<String, Object> r = new Map<String, Object>();
        r.put('hasSubText', false);
        switch on SW.MetricName {
            when 'Revenue' { return Revenue(SW, r); }	
            when 'Card_Payments_Percentage' { return CardPaymentsPercentage(SW, r); }
            when 'Average Invoice' { return AverageInvoice(SW, r); }
            when 'Hourly Revenue' { return HourlyRevenue(SW, r); }
            when 'Takeaway Percentage' { return TakeawayPercentage(SW, r); }
            when 'Top Food Items' { return TopFoodItems(SW, r); }
            when 'Top Beverage Items' { return TopBeverageItems(SW, r); }
            when 'Food and Drinks Ratios' { return FoodDrinksRatios(SW, r); }
            when else { return Empty(r); }
        }
    }
    
    public Map<String, Object> process(InsightsSender.SectionWrapper SWw, Map<String, Object> r) {
        return RevenueWatermarkMerge(r, SWw);
    }
    
    public Map<String, Object> TopFoodItems(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        switch on SW.Version {
            when '2' {
                List<ItemList> Items = new List<ItemList>();
                for (Object Item : (List<Object>)SW.Value.get('Value')) {
                    Items.add(new ItemList(
                        (String)(((Map<String, Object>)Item).get('i')),
                        (Integer)(((Map<String, Object>)Item).get('d'))
                    ));
                }
                r.put('subTextList', Items);
                r.put('hasSubTextList', true);
                r.put('isKpi', true);
                r.put('isTopItem', true);
				r.put('headText', s(j.x('TopFoodItems').x('Header').m, SW.Language));
                r.put('img', 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/411ad15b-4524-47f2-9a6e-3dcce3d6e888/395x332.png');
                r.put('widthClass', 'optCol');
                r.put('isHalf', true);
            }
            when else { 
                r.put('isKpi', false);
            }
        }
        return r;
    }
    
    public Map<String, Object> TopBeverageItems(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        switch on SW.Version {
            when '2' {
                List<ItemList> Items = new List<ItemList>();
                for (Object Item : (List<Object>)SW.Value.get('Value')) {
                    Items.add(new ItemList(
                        (String)(((Map<String, Object>)Item).get('i')),
                        (Integer)(((Map<String, Object>)Item).get('d'))
                    ));
                }
                r.put('subTextList', Items);
                r.put('hasSubTextList', true);
                r.put('isKpi', true);
                r.put('isTopItem', true);
				r.put('headText', s(j.x('TopBeverageItems').x('Header').m, SW.Language));
                r.put('img', 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/0de50b2f-83eb-4dcf-9c32-1e75196b5ba7/325x371.png');
                r.put('widthClass', 'optCol');
                r.put('isHalf', true);
            }
            when else { 
                r.put('isKpi', false);
            }
        }
        return r;
    }
    
    public Map<String, Object> FoodDrinksRatios(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        switch on SW.Version {
            when '2' {
                r.put('isKpi', true);
                r.put('isChart', true);
                r.put('isPieChart', true);
                r.put('hasSubText', false);
				r.put('headText', s(j.x('FoodDrinksRatios').x('Header').m, SW.Language));
                r.put('widthClass', 'fullCol');
                Map<String, Object> Slices = m(SW.Value, 'current');
                if (Slices.keySet().size() == 3) {
                    List<PieChartLegendItem> Legend = new List<PieChartLegendItem>();
                    List<String> Colors = new List<String>{'00a3e0','66c8ec','f4f3f2'};
                    Integer ItemCount = 0;
                    for (String SliceName : Slices.keySet()) {
                        Decimal Percentage = (Decimal)Slices.get(SliceName);
	                    Legend.add(new PieChartLegendItem(
                            s(j.x('FoodDrinksRatios').x(SliceName).m, SW.Language),
                            '#' + Colors[ItemCount],
                            LegendPercVal(Percentage)
                        ));
                        ItemCount++;
                    }
                    r.put('legend', Legend);
                    r.put('imgChart', 'https://image-charts.com/chart?chco='+Colors[1]+'%7C'+Colors[2]+'%7C'+Colors[0]+'&chd=t%3A'+Slices.values()[1]+'%2C'+Slices.values()[2]+'%2C'+Slices.values()[0]+'&chma=0%2C0%2C30%2C0&chs=700x700&cht=p3&chf=bg%2Cs%2C00000000');
                } else {
                    r.put('isKpi', false);
                }
            }
            when else { 
                r.put('isKpi', false);
            }
        }
        return r;
    }
    
    public Map<String, Object> TakeawayPercentage(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        String numText = PercVal((Decimal)SW.Value.get('current'));
        r.put('isKpi', true);
		r.put('headText', s(j.x('TakeawayPercentage').x('Header').m, SW.Language));
        switch on SW.Version {
            when '2' {
                r.put('img', 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/d289a055-082b-48e8-af84-1f71b0e9e586/318x388.png');
                r.put('widthClass', 'optCol');
            }
            when else { 
                r.put('hasNum', true);
                r.put('fsh', fsh(numText));
            }
        }
        r.put('numText', numText);
        String subText = s(j.x('TakeawayPercentage').x('LastWeekWas').m, SW.Language);
       	subText += ' ' + PercVal((Decimal)SW.Value.get('last'));
        Decimal current = ((Decimal)SW.Value.get('current')).round(System.RoundingMode.HALF_UP);
        Decimal last = ((Decimal)SW.Value.get('last')).round(System.RoundingMode.HALF_UP);
        if (current > last) { r.put('upArrow', true); } else if (current < last) { r.put('dnArrow', true); }
        r.put('hasSubText', true);
        r.put('subText', subText);
        Decimal fss = fss(subText);
        r.put('fss', String.valueOf(fss));
        if (fss < 10) r.put('hasSubText', false);
        return r;
    }
    
    public Map<String, Object> CardPaymentsPercentage(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        String numText = PercVal((Decimal)SW.Value.get('percentage'));
        switch on SW.Version {
            when '2' {
                r.put('img', 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/bdfc669a-20cd-4234-b9f3-9c83588098ea/431x372.png');
                r.put('widthClass', 'optCol');
            }
            when else { 
                r.put('hasNum', true);
                r.put('fsh', fsh(numText));
            }
        }
        r.put('isKpi', true);
		r.put('headText', s(j.x('CardPaymentsPercentage').x('Header').m, SW.Language));
        r.put('numText', numText);
        if (numText != '0%') {
            String subText = '';
            Boolean hasSubText = true; 
            switch on s(SW.Value, 'comparison') {
                when 'at industry level' { subText = s(j.x('CardPaymentsPercentage').x('AroundAverage').m, SW.Language);}
                when 'below industry' { subText = s(j.x('CardPaymentsPercentage').x('BelowAverage').m, SW.Language);}
                when 'abouve industry' { subText = s(j.x('CardPaymentsPercentage').x('AboveAverage').m, SW.Language);}
                when else { hasSubText = false; }                
            }
            r.put('hasSubText', hasSubText);
            if (hasSubText) {
                r.put('subText', subText);
                if (SW.Version == null || SW.Version == '1') {
                    Decimal fss = fss(subText); 
                    r.put('fss', String.valueOf(fss)); 
                    if (fss < 10) r.put('hasSubText', false); 
                }
            }
        }
        return r;
    }
    
    public Map<String, Object> HourlyRevenue(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        system.debug(json.serialize(SW.Value));
        r.put('isKpi', true);
		r.put('headText', s(j.x('HourlyRevenue').x('Header').m, SW.Language));
        r.put('hasFullChart', true);
        String BackgroundColor = '00000000';
        String BarColor = '414344';
        String Dimensions = '700x450';
        if (SW.Version == '2') {
            r.put('widthClass', 'fullCol');
            r.put('isChart', true);
            BackgroundColor = 'ffffff';
            BarColor = '00a3e0';
            Dimensions = '950x350';
        }
        List<Object> Hours = (List<Object>)SW.Value.get('hours');
        Map<Integer,Integer> IndexMap = new Map<Integer,Integer>();
        Boolean subsequent = false;
        for (Integer i = 0; i < Hours.size(); i++) {
            IndexMap.put((Integer)Hours[i], i);
        }
        String AxValues = '';
        String RvValues = '';
        Integer LastHour = ((Integer)Hours[Hours.size()-1] < (Integer)Hours[0] ? (Integer)Hours[Hours.size()-1] + 24 : (Integer)Hours[Hours.size()-1]);
        system.debug(string.valueOf(LastHour));
        for(Integer x = (Integer)Hours[0]; x <= LastHour; x++) {
            AxValues += EncodingUtil.urlEncode('|', 'UTF-8') + String.valueOf(x > 23 ? x - 24 : x);
            if (x != (Integer)Hours[0]) RvValues += ',';
            String RvValue = null;
            try{ RvValue = String.valueOf((Decimal)(((List<Object>)SW.Value.get('values'))[IndexMap.get(x > 23 ? x - 24 : x)])); } catch(exception e) { RvValue = '0'; }
            RvValues += RvValue;
        }
        r.put('chartUrl', 'https://image-charts.com/chart?chco=' + BarColor + '&chf=a%2Cs%2C' + BackgroundColor + '&chls=8&chs=' + Dimensions + '&cht=bvs&chtt=%20&chxs=0%2C414344%2C30&chxt=x&chxl=0:' + AxValues + '&chd=t:' + RvValues);
        return r;
    }
    
    public Map<String, Object> AverageInvoice(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        r.put('isKpi', true);
        String numText = CurrencyString((Decimal)SW.Value.get('current'), SW.CurrCode);
        r.put('numText', numText);
        switch on SW.Version {
            when '2' {
                r.put('img', 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/5268a8ef-c956-48d2-b858-fec6c3ba1494/355x377.png');
                r.put('widthClass', 'optCol');
            }
            when else { 
                r.put('hasNum', true);
                r.put('fsh', fsh(numText));
            }
        }
		r.put('headText', s(j.x('AverageInvoice').x('Header').m, SW.Language));
        Decimal change = (Decimal)SW.Value.get('change');
        if (change != null) {
            change = change * 100.0;
            r.put('hasSubText', true);
            String subText = '';
            if (change > 0) {
                subText += PercVal(change) + ' ' + s(j.x('AverageInvoice').x('HigherThanLast').m, SW.Language);
                subText += ' ' + s(j.x('Weekday').x(YeDayNum).m, SW.Language);
                r.put('upArrow', true);
            } else if (change < 0) {
                subText += PercVal(change) + ' ' + s(j.x('AverageInvoice').x('LowerThanLast').m, SW.Language);
                subText += ' ' + s(j.x('Weekday').x(YeDayNum).m, SW.Language);
                r.put('dnArrow', true);
            } else {
                subText += s(j.x('AverageInvoice').x('NoDifferenceFromLast').m, SW.Language);
                subText += ' ' + s(j.x('Weekday').x(YeDayNum).m, SW.Language);
            }
            r.put('subText', subText);
            Decimal fss = fss(subText);
            r.put('fss', String.valueOf(fss));
            if (fss < 10) r.put('hasSubText', false);
        }
        return r;
    }
    
    public String PercVal(Decimal Perc) {
        Perc = Math.abs(Perc);
        if (Perc == 0) return '0%';
        String s = Perc.round(System.RoundingMode.HALF_UP).format();
        if (s == '0') { return '<1%'; } else { return s + '%'; }
    }
    
    public String LegendPercVal(Decimal Perc) {
        if (Perc == 0.0) return '0.0 %';
        String s = String.valueOf(Perc.setScale(1, System.RoundingMode.HALF_UP));
        if (s == '0') { return '<1 %'; } else { return s + ' %'; }
    }
    
    public Map<String, Object> Revenue(InsightsSender.SectionWrapper SW, Map<String, Object> r) {
        r.put('isKpi', true);
		r.put('headText', s(j.x('Revenue').x('Header').m, SW.Language));
        String numText = CurrencyString((Decimal)SW.Value.get('Value'), SW.CurrCode);
        r.put('numText', numText);
        switch on SW.Version {
            when '2' {
                r.put('img', 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/0c463fc4-fef6-4499-a754-6362632fd692/412x345.png');
                r.put('widthClass', 'fullCol');
            }
            when else { 
                r.put('hasNum', true);
                r.put('fsh', fsh(numText));
            }
        }
        return r;
    }
    
    public Map<String, Object> RevenueWatermarkMerge(Map<String, Object> r, InsightsSender.SectionWrapper SWw) {
        String subText = RevenueRankTop(SWw) + ' ';
        if (b(SWw.Value, 'overall')) { subText += s(j.x('Day').m, SWw.Language); } else { subText += s(j.x('Weekday').x(YeDayNum).m, SWw.Language); }
        String SinceDate = (String)SWw.Value.get('date');
        if (SinceDate == null) {
            subText += ' ' + s(j.x('Revenue').x('Ever').m, SWw.Language);
        } else {
            subText += ' ' + s(j.x('Revenue').x('Since').m, SWw.Language) + ' ' + Date.valueOf(SinceDate + ' 12:00:00').format();
        }
        r.put('subText', subText);
        if (SWw.Version == null || SWw.Version == '1') {
            r.put('hasSubText', true);
            Decimal fss = fss(subText);
            r.put('fss', String.valueOf(fss));
            if (fss < 8) r.put('hasSubText', false);
        }
        return r;
    }
    
    public String RevenueRankTop(InsightsSender.SectionWrapper SW) {
        return s(j.x('Revenue').x('RankTop').x(s(SW.Value, 'rank')).x(s(SW.Value, 'top')).m, SW.Language);
    }
    
    public class PieChartLegendItem {
        public String label;
        public String color;
        public String perc;
        public PieChartLegendItem(String l, String c, String p) {
            label = l;
            color = c;
            perc = p;
        }
    }
    
    public class ItemList {
        public String listText;
        public String listImg;
        public Boolean listImgSmall;
        public ItemList(String name, Integer diff) {
            listText = name;
            listImgSmall = false;
            if (diff == null){
                listImg = null;
            } else if (diff == 1) {
                listImg = 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/ab85bf4f-ad6e-4bb8-9bdb-cf6ae03163b1/31x30.png';
            } else if (diff == -1) {
                listImg = 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/97a93f94-7b37-413c-9354-6973ce03b2c3/31x30.png';
            } else if (diff > 1) {
                listImg = 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/10f76381-d76b-4a38-8d26-2ab9d5d8a470/31x30.png';
            } else if (diff < -1) {
                listImg = 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/5a91851b-3463-4969-afd2-bf00a8dae993/31x30.png';
            } else {
                listImg = 'http://cdn.mcauto-images-production.sendgrid.net/920c5bf7a998ecab/a37facda-cc5f-4a75-b85c-562a033511c9/19x19.png';
                listImgSmall = true;
            }
        }
    }
    
    public Map<String, Object> Empty(Map<String, Object> r) {
        r.put('isKpi', false);
        return r;
    }
    
    public String fsh(String s) {
        return String.valueOf(6*math.max(2.0,s.length()*(-0.375)+9.875));
    }
    
    public Decimal fss(String s) {
        return math.min(36.0,67-s.length())/3;
    }
    
    public String CurrencyString(Decimal d, String c) {
        String cs = d.format();
        return cs + (cs.length() == cs.indexOfIgnoreCase(',') + 2 ? '0' : '') + ' ' + (c == 'EUR' ? '€' : c);
    }
    
    public Map<String, Object> m (Map<String, Object> m, String s) {
        system.debug(json.serialize(m));
        system.debug(s);
        return (Map<String, Object>)m.get(s);
    }
    
    public String s (Map<String, Object> m, String s) {
        try{ return (String)m.get(s); } catch(exception e) {
            switch on e.getMessage() {
                when 'Invalid conversion from runtime type Integer to String' { return String.valueOf((Integer)m.get(s)); }
                when 'Invalid conversion from runtime type Boolean to String' { return String.valueOf((Boolean)m.get(s)); }
                when else { return String.valueOf((Integer)m.get(s)); }
            }
        }
    }
    
    public Boolean b (Map<String, Object> m, String s) {
        return (Boolean)m.get(s);
    }
    
}