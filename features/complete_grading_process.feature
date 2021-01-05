@javascript
Feature: Complete grading process
  As a teaching assistant
  I want to grade an assignment or project on Helli
  So that I can spend less time on grading

  Scenario: Grading a simple assignment without input files and created files
    * I want to grade an exercise called Day 1 from CSC 116 (001)
    * I have logged in
    * I go to courses page and create a course called CSC 116 (001)
    * I go to course CSC 116 (001) and create an Exercise called Day 1
    * I go to assignment Day 1
    * I add a program called Main.java
    * I upload a moodle grade worksheet using features/fixtures/Day 1/Grades-CSC 116 (001) TEST 2020-Day 1-123456.csv
    * I go to Submissions page from the assignment sidebar
    * I upload a submissions zip file using features/fixtures/Day 1/CSC 116 (001) TEST 2020-Day 1-123456.zip
    * I go to Rubric page from the assignment sidebar
    * I create a rubric item Compile with primary file Main.java and default settings
    * I create a rubric item Execute with primary file Main.java and default settings
    * I create a rubric item Checkstyle with primary file Main.java and default settings
    * I go to Automated Grading page from the assignment sidebar
    * I run Compile for Main.java without options
    * I run Execute for Main.java without options
    * I go to Grades page from the assignment sidebar
