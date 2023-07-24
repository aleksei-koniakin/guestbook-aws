JetBrains Guestbook Sample Application
======================================

This is a two-tiered sample application with a Spring Boot 
backend, and a React frontend. 

See the README.md in the frontend and backend folders 
respectively.

How to open this project in IDEA
--------------------------------

1. Open the project from VCS / Disk
2. Choose "Project Files" in the dropdown near the Project tool window
3. Find `backend/build.gradle.kts`, right-click and choose to link the Gradle project.
4. Now open the Project Structure screen (Ctrl+Alt+Shift+S or Cmd+;). Use the '+' button
   above the module list. Choose 'New Module', make sure 'Java' is selected, choose 'Next',
   make sure the 'Content Root' field is set to the repository root. Click 'Finish'.
5. Now, in the dropdown near the Project tool window, select "Project".
6. You can also add the TeamCity configuration by going to the `.teamcity` folder
   right-clicking the `pom.xml` file, and choosing 'Add as Gradle project'
7. You may want to install the Terraform plugin for the `*.tf` files.


Runnning Debug locally:
 - start "Backend" configuration for backend
 - start "Frontend" configuration for the frontend.
