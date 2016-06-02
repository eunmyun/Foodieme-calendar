//
//  AddToCalendarViewController.swift
//  ClarifaiApiDemo
//
//  Created by MyungJin Eun on 6/1/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//


import UIKit
import EventKit

class AddToCalendarViewController: UIViewController {

    var eventTitle : String = ""
    var dateString : String = ""
    var timeString : String = ""
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.text = eventTitle
        dateField.textColor = UIColor.lightGrayColor()
        dateField.userInteractionEnabled = false
        timeField.textColor = UIColor.lightGrayColor()
        timeField.userInteractionEnabled = false
    }
    
    @IBAction func clickTextbox(sender: UITextField) {
        sender.text = nil
        sender.textColor = UIColor.blackColor()
    }
    
    @IBAction func selectDate(sender: AnyObject) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" //format style. you can change according to yours
            self.dateString = dateFormatter.stringFromDate(date)
            self.dateField.textColor = UIColor.blackColor()
            self.dateField.text = self.dateString
        }
    }
    
    @IBAction func selectTime(sender: AnyObject) {
        DatePickerDialog().show("Select Start Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Time) {
            (date) -> Void in
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a" //format style. you can change according to yours
            self.timeString = dateFormatter.stringFromDate(date)
            self.timeField.textColor = UIColor.blackColor()
            self.timeField.text = self.timeString
        }
    }
    
    
    @IBAction func addEvent(sender: AnyObject) {
        let eventStore = EKEventStore()
        var event: EKEvent = EKEvent(eventStore: eventStore)
        // 2
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
        case .Authorized:
            insertEvent(eventStore)
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            // 3
            eventStore.requestAccessToEntityType(.Event, completion:
                {[weak self] (granted: Bool, error: NSError?) -> Void in
                    if granted {
                        self!.insertEvent(eventStore)
                        
                    } else {
                        print("Access denied")
                    }
                })
        default:
            print("Case Default")
        }
    }
    
    
    func insertEvent(store: EKEventStore) {
        // 1
        let calendars = store.calendarsForEntityType(.Event)
            as! [EKCalendar]
        
        for calendar in calendars {
            // 2
            if calendar.title == "ioscreator" {
                // 3
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
                var dateAsString = "\(dateString) \(timeString)"
                let startDate = dateFormatter.dateFromString(dateAsString)!
                
                let endDate = startDate.dateByAddingTimeInterval(1 * 60 * 60)
                
 
                // 4
                // Create Event
                var event = EKEvent(eventStore: store)
                event.calendar = calendar
                
                event.title = titleField.text!
                event.startDate = startDate
                event.endDate = endDate
                
                // 5
                // Save Event in Calendar
                var error: NSError?
                var result: ()
                do {
                    result = try store.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                } catch {
                    print("it doesn't work")
                }
                
                //if result == false {
                if let theError = error {
                    print("An error occured \(theError)")
                }
                //}
            }
        }
    }
    
    
}

