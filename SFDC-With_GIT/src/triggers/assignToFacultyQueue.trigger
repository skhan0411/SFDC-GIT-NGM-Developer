trigger assignToFacultyQueue on Course_Application__c (before insert) {
    
    System.debug(LoggingLevel.DEBUG, '*** Executing Apex Trigger assignToFacultyQueue...');
    
    try {
        
        // retrieve the queue information
        System.debug(LoggingLevel.DEBUG, '*** Retrieving Force.com Queues...');
        List<Group> queues = [SELECT Id, DeveloperName, Type
                              FROM Group
                              WHERE Type = 'Queue'];
        
        // Map to hold Queue information mapped to each queue code
        Map<string, Group> facultyQueues = new Map<string, Group>();
        
        // construct the map of Faculty Queues        
        for (Group queue : queues) {
            facultyQueues.put(queue.DeveloperName, queue);
        }
        
        // Map to hold Queue Mappings
        // string = the Faculty the queue is assigned to
        // string = the Force.com unique Id for the queue
        Map<string, string> facultyQueueMappings = new Map<string, string>();
         
        // get the custom setting information
        System.debug(LoggingLevel.DEBUG, '*** Retrieving Faculty to Queue Mappings...');
        List<FacultyQueueMapping__c> facultyQueueMappingsList = FacultyQueueMapping__c.getAll().values();

        // Now, physically map each actual queue to a Faculty
        for (FacultyQueueMapping__c facultyQueueMapping : facultyQueueMappingsList) {
            Group facultyQueue = facultyQueues.get(facultyQueueMapping.QueueCode__c);
            
            // if the queue exists, map it to the Faculty
            if (facultyQueue != null) {
                facultyQueueMappings.put(facultyQueueMapping.Faculty__c, facultyQueue.Id);
                System.debug(LoggingLevel.DEBUG, '*** Constructed Faculty Queue Mapping - '
                                                + facultyQueueMapping.Faculty__c + ', '
                                                + facultyQueue.Id);
            }
        }
                                    
        // note bulkified trigger logic - always allow for this
        for (Course_Application__c courseApplication : trigger.new) {
                        
            // assign Course Application to Faculty queue
            string queueId = facultyQueueMappings.get(courseApplication.Course_Faculty__c);
            if (queueId != null) {
                System.debug(LoggingLevel.DEBUG,'*** Re-assigning Course Application '
                    + courseApplication.OwnerId + ' to ' + queueId);
                courseApplication.OwnerId = queueId;
                System.debug(LoggingLevel.DEBUG, '*** Assigned Course Application to '
                            + queueId);
            } else {
                // assign Course Application to Exception Queue
                System.debug(LoggingLevel.DEBUG, '*** Faculty Assignment Exception Detected');
                string exceptionQueueId = facultyQueueMappings.get('Exception');
                courseApplication.OwnerId = exceptionQueueId;
                System.debug(LoggingLevel.DEBUG, '*** Assigned Course Application to '
                            + exceptionQueueId);
            }
            
        }
            
    } catch (Exception ex) {
        System.debug(LoggingLevel.ERROR, '*** ERROR Assigning Course Application to Faculty - '
                    + ex.getMessage()); 
    }
}