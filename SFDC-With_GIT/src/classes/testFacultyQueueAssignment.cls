@isTest
private class testFacultyQueueAssignment{
    
    // Set number of course applications to test bulkified trigger with
    static private integer MAX_BULK_TEST_SIZE = 10;

    // create an Admissions Officer to use for testing
    static User createAdmissionsOfficeUser() {
        // create Admissions Office user to run test as
        Profile p = [select id from profile where name = 'Admissions Office'];
        User u = new User(alias = 'test123', email='test1234@noemail.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing',
            languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.id,
            country='United States',
            timezonesidkey='America/Los_Angeles',
            username='test123@noemail.com');
        insert u;
        
        return u;
    }
    
    // create an Applicant to use for testing
    static Applicant__c createApplicant() {
        // create applicant to link to Course Applications
        Date DOB = Date.parse('01/01/1980');
        Applicant__c applicant = new Applicant__c(
            Address__c='123 Test Ave',
            Cell__c='555 7777',
            Date_of_Birth__c=DOB,
            Email__c='test123@noemail.com',
            Gender__c='Male',
            Given_Names__c='Dale',
            Phone__c='555 8888',
            Salutation__c='Mr',
            Surname__c='Carnegie'
            );
        insert applicant;
        
        return applicant;
    }
    
    // create a course to use for testing
    static Course__c createCourse() {
        // create Business course to link to Course Applications
        Course__c course = new Course__c(
            Achievement__c='Degree',
            Description__c='Accounting Degree',
            Faculty__c='Business',
            Faculty_Course_Area__c='Accounting',
            Name__c='Bachelor of Accounting');
        insert course;
        
        return course;
    }
    
    
    // create Test Queues
    static Map<string, Group> createQueues() {
        // get the queue information
        List<Group> queues = [SELECT Id, Name, DeveloperName, Email, Type
                              FROM Group
                              WHERE Type = 'Queue'];
        
        // Map to hold Queue information
        Map<string, Group> facultyQueues = new Map<string, Group>();
        
        // Construct the Queue Map
        for (Group queue : queues) {
            facultyQueues.put(queue.DeveloperName, queue);
        }
        
        return facultyQueues;
    }
    
    // create Custom Settings to map Faculties to Queues
    // Note that this is required for Test Classes, even if the Custom Settings
    // exist in the Salesforce Org you are testing against
    static void createFacultyQueueCustomSettings(Boolean exceptionQueueOnly) {
        List<FacultyQueueMapping__c> facultyQueueMappings = new List<FacultyQueueMapping__c>();
        
        FacultyQueueMapping__c exceptionQueueMapping = new FacultyQueueMapping__c(
            Name = 'ExceptionQueue',
            Faculty__c = 'Exception',
            QueueCode__c = 'Course_Application_Exception_Queue');
        facultyQueueMappings.add(exceptionQueueMapping);
        
        if (!exceptionQueueOnly) {
            FacultyQueueMapping__c businessQueueMapping = new FacultyQueueMapping__c(
                Name = 'BusinessFacultyTestQueue',
                Faculty__c = 'Business',
                QueueCode__c = 'Business_Faculty_Course_Applications');
            facultyQueueMappings.add(businessQueueMapping);
        }
                
        insert facultyQueueMappings;
                 
    }
    
    // Ensure that trigger is bulkified and assigning Course Applications
    // to the correct Faculty
    static testMethod void testFacultyAssignmentTrigger_Bulk() {
        // list of Course Applications to add
        List<Course_Application__c> courseApps = new List<Course_Application__c>();
        
        // create Admissions Office user to run test as
        User u = createAdmissionsOfficeUser();
        
        // create applicant to link to Course Applications
        Applicant__c applicant = createApplicant();
        
        // create course to link to Course Application
        Course__c course = createCourse();
                
        // get Faculty Queues
        Map<string, Group> facultyQueues = createQueues();
        
        // create the Custom Settings to map Faculties to Queues
        createFacultyQueueCustomSettings(false);
        
        // create Course Applications
        for (integer i=0; i < MAX_BULK_TEST_SIZE; i++) {
            Course_Application__c courseApplication = new Course_Application__c(
                Applicant__c = applicant.Id, Course__c = course.Id);
            courseApps.add(courseApplication);  
        }
                
        // Switch to runtime context
        Test.startTest();
        
        // run as Admissions Officer user to test security and rights
        System.runAs(u) {
        
            insert courseApps;
            
        }
        
        // Switch back to original context
        Test.stopTest();
        
        // query course Applications to ensure that they were added correctly
        Group businessFacultyQueue = facultyQueues.get('Business_Faculty_Course_Applications');
        for(Course_Application__c cApp : [select Id, OwnerId, Applicant__c, Course__c
                                          from Course_Application__c])
        {
            System.assertEquals(cApp.Applicant__c, applicant.Id);
            System.assertEquals(cApp.Course__c, course.Id);
            System.assertEquals(businessFacultyQueue.Id, cApp.OwnerId);
        }

    }
    

    // trigger an assignment exception by trying to assign a Course Application
    // to a Faculty that has no queue assigned to it
    static testMethod void testFacultyAssignmentTrigger_Exception() {
        
                
        // create Admissions Office user to run test as
        User u = createAdmissionsOfficeUser();
        
        // create applicant to link to Course Applications
        Applicant__c applicant = createApplicant();
        
        // create course to link to Course Applications
        Course__c course = createCourse();
        
        // get Faculty Queues
        Map<string, Group> facultyQueues = createQueues();
         
        // create the Custom Settings to map Faculties to Queues
        // pass "false" to create only the Exception Queue
        // which will trigger an exception during the 
        // faculty assignment process
        createFacultyQueueCustomSettings(true);
        
        // Course Application to add
        Course_Application__c courseApp = new Course_Application__c(
            Applicant__c = applicant.Id,
            Course__c = course.Id);
        
        // Switch to runtime context
        Test.startTest();
        
        // run as Admissions Officer user to test security and rights
        System.runAs(u) {
        
            insert courseApp;
            
        }
        
        // Switch back to original context
        Test.stopTest();
        
        // query Course Application to ensure it has been assigned to Exception Queue
        Group exceptionQueue = facultyQueues.get('Course_Application_Exception_Queue');
        Course_Application__c cApp = [select Id, OwnerId, Applicant__c, Course__c
                                          from Course_Application__c];
 
        // verify that assignment exception has been handled correctly
        System.assertEquals(cApp.Applicant__c, applicant.Id);
        System.assertEquals(cApp.Course__c, course.Id);
        System.assertEquals(exceptionQueue.Id, cApp.OwnerId);
           
    }
}