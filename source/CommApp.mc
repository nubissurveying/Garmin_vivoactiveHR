//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage;

var page = 0;
var strings = ["","","","",""];
var stringsSize = 5;
var mailMethod;
var phoneMethod;
var crashOnMessage = false;
var startRecording = 0;


class CommExample extends App.AppBase {
	var uploadTimer;
	var uploadCount;
    function initialize() {
        App.AppBase.initialize();

        mailMethod = method(:onMail);
        phoneMethod = method(:onPhone);
        if(Comm has :registerForPhoneAppMessages) {
            Comm.registerForPhoneAppMessages(phoneMethod);
        } else {
            Comm.setMailboxListener(mailMethod);
        }
//        uploadFileTest();
//		for(var i = 0; i < 20; i++){
//			var message = "";
//			for(var j = 0; j < 50; j++){
//				message = message + "123456789 123456";
//			}
//			Storage.setValue(i, message);
//		}
//		uploadFileTest();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [new CommView(), new CommInputDelegate()];
    }

    function onMail(mailIter) {
        var mail;

        mail = mailIter.next();

        while(mail != null) {
            var i;
            for(i = (stringsSize - 1); i > 0; i -= 1) {
                strings[i] = strings[i-1];
            }
            strings[0] = mail.toString();
            page = 1;
            mail = mailIter.next();
        }

        Comm.emptyMailbox();
        Ui.requestUpdate();
    }

    function onPhone(msg) {
        var i;

//        if((crashOnMessage == true) && msg.data.equals("Hi")) {
//            foo = bar;
//        }
        
        if(msg.data.equals("start")) {
            startRecording = 1;
        } else if (msg.data.equals("stop")){
        	startRecording = 2;
        } else if (msg.data.equals("collect")){
        	uploadFiles();
//        	uploadFileTest();
        }

        for(i = (stringsSize - 1); i > 0; i -= 1) {
            strings[i] = strings[i-1];
        }
        strings[0] = msg.data.toString();
        page = 1;

        Ui.requestUpdate();
    }
    function uploadFileTest(){
    	uploadTimer = new Timer.Timer();
    	uploadCount = 0;
    	
    	uploadTimer.start(method(:uploadTimerCallbackTest), 2000, true);
    }
    
    
    function uploadTimerCallbackTest() {
    	var listener = new CommListener();
    	var message = Storage.getValue(uploadCount);
    	
    	if(uploadCount == 20) {
    		message = "upload ends";
    	}
    	message = message + " " + uploadCount;
//    	Sys.println(message + " " + uploadCount);
    	Comm.transmit(message, null, listener);
    	
    	if(uploadCount == 20){
    		uploadTimer.stop();
    		uploadCount = 0;
    	}
    	uploadCount++;
    }
    
    
    
    function uploadFiles(){
    	uploadTimer = new Timer.Timer();
    	uploadCount = 0;
    	
    	uploadTimer.start(method(:uploadTimerCallback), 1000, true);
    	
//    	for(var i = 0; i < storeId; i++){	
//    		var message = Storage.getValue(i);
//    		Comm.transmit(message, null, listener);
//    		
//    	}
//    	storeId = 0;
//    	Sys.println("upload ends");
//    	Comm.transmit("upload ends", null, listener);
//    	
    }
    function uploadTimerCallback() {
    	var listener = new CommListener();
    	var message = Storage.getValue(uploadCount);
    	if(uploadCount == storeId) {
    		message = "upload ends";
    	}
    	Comm.transmit(message, null, listener);
    	
    	if(uploadCount == storeId){
    		uploadTimer.stop();
    		uploadCount = 0;
    	}
    	uploadCount++;
    }

    

}