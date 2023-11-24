trigger DeleteDemo on Event (Before Delete) {
   
           for (Event evt : trigger.old) {  
                if([select id from permissionsetassignment where permissionset.name= 'Delete_Events' and assigneeid=:userinfo.getuserid()].size()==0)
 {           
                evt.adderror(Label.Error_Deleting_Demos);  
                
 }        

       }
    }