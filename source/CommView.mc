//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.Math;
using Toybox.Application.Storage;

var storeId;

class CommView extends Ui.View {
    var screenShape;
	var dataTimer;
	var count;
	var accel;
	var message;
	var fre ;
	var freCount ;
	var accBuffer;
	
	var idToSwitchInterval;
	var secondFre;
	var storeLimit;
	var storeBuffer;
	var storeCount;
    function initialize() {
        View.initialize();      
    }
	function startRecord(){
		dataTimer = new Timer.Timer();
        dataTimer.start(method(:timerCallback), 50, true);
        count = 0;
        fre = 20;
        secondFre = fre * 30;
        freCount = 0;
        accBuffer = 0;
        storeId = 0;
        idToSwitchInterval = 60;
        storeBuffer = "";
        storeCount = 0;
        storeLimit = 60;
	}
    function onLayout(dc) {
        screenShape = Sys.getDeviceSettings().screenShape;
    }
    function timerCallback() {
    	var info = Sensor.getInfo();
//		var listener = new CommListener();
		var curr = 0;
		
		if (info has :accel && info.accel != null) {
            accel = info.accel;
            var xAccel = accel[0];
            var yAccel = accel[1];
            var zAccel = accel[2];
            curr = Math.sqrt(xAccel * xAccel + yAccel * yAccel + zAccel * zAccel) / (100) ;
            accBuffer += curr;
            freCount ++;
            
        }
        if(freCount >= fre && storeId < idToSwitchInterval){
        	count++;
        	message = accBuffer;
        	if (info has :heartRate && info.heartRate != null) {
        		message = message + " " + info.heartRate;
        	}
	        Sys.println(message);
	        storeMessage(message);
//			Comm.transmit(message, null, listener);
			Ui.requestUpdate();
			freCount = 0;
			accBuffer = 0;
        } else if(freCount >= secondFre && storeId >= idToSwitchInterval){
        	count++;
        	message = accBuffer;
        	if (info has :heartRate && info.heartRate != null) {
        		message = message + " " + info.heartRate;
        	}
	        Sys.println(message);
	        storeMessage(message);
//			Comm.transmit(message, null, listener);
			Ui.requestUpdate();
			freCount = 0;
			accBuffer = 0;
        	
        }
        
    }
	function storeMessage(message){
		storeCount ++;
		storeBuffer = storeBuffer + message + "\n";
		if(storeCount >= storeLimit){
			Storage.setValue(storeId, storeBuffer);
			storeId++;
			storeBuffer = "";
			storeCount = 0;
			Sys.println(storeId - 1);
			
		}
	}
    function drawIntroPage(dc) {
        if(Sys.SCREEN_SHAPE_ROUND == screenShape) {
            dc.drawText(dc.getWidth() / 2, 25,  Gfx.FONT_SMALL, message, Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 55, Gfx.FONT_SMALL, "Test", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 80,  Gfx.FONT_TINY,  "Connect a phone then", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 100,  Gfx.FONT_TINY,  "use the menu to send", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 120,  Gfx.FONT_TINY,  "strings to your phone", Gfx.TEXT_JUSTIFY_CENTER);
        } else if(Sys.SCREEN_SHAPE_SEMI_ROUND == screenShape) {
            dc.drawText(dc.getWidth() / 2, 20,  Gfx.FONT_MEDIUM, "Communications test", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 50,  Gfx.FONT_SMALL,  "Connect a phone", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 70,  Gfx.FONT_SMALL,  "Then use the menu to send", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 90,  Gfx.FONT_SMALL,  "strings to your phone", Gfx.TEXT_JUSTIFY_CENTER);
        } else if(dc.getWidth() > dc.getHeight()) {
            dc.drawText(10, 20,  Gfx.FONT_MEDIUM, "Communications test", Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 50,  Gfx.FONT_SMALL,  "Connect a phone", Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 70,  Gfx.FONT_SMALL,  "Then use the menu to send", Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 90,  Gfx.FONT_SMALL,  "strings to your phone", Gfx.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(10, 20, Gfx.FONT_MEDIUM, message, Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 40, Gfx.FONT_MEDIUM, storeId, Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 70, Gfx.FONT_SMALL, "Connect a phone", Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 90, Gfx.FONT_SMALL, "Then use the menu", Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 110, Gfx.FONT_SMALL, "to send strings", Gfx.TEXT_JUSTIFY_LEFT);
            dc.drawText(10, 130, Gfx.FONT_SMALL, "to your phone", Gfx.TEXT_JUSTIFY_LEFT);
        }
        
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        if(page == 0) {
            drawIntroPage(dc);
        } else {
            var i;
            var y = 70;
			
            dc.drawText(dc.getWidth() / 2, 20,  Gfx.FONT_MEDIUM, message, Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 40,  Gfx.FONT_MEDIUM, "Strings Received:", Gfx.TEXT_JUSTIFY_CENTER);
            for(i = 0; i < stringsSize; i += 1) {
                dc.drawText(dc.getWidth() / 2, y,  Gfx.FONT_SMALL, strings[i], Gfx.TEXT_JUSTIFY_CENTER);
                y += 20;
            }
        }
        
        if(startRecording == 1) {
        	Storage.clearValues();
        	startRecord();
        	startRecording = 0;
        } else if(startRecording == 2){
        	dataTimer.stop();
        	Storage.setValue(storeId, storeBuffer);
        	storeId++;
        	startRecording = 0;
        }
 
    }
}