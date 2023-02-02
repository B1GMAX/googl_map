On the first screen, registration with Google is implemented

On the second screen, the display of the current user and all users is implemented, by clicking on the user, a window
opens with information about this user, and if this is not the current user, then you can click on the button and it
will create a path to this user. The AppBar has a button that moves the camera to our current position. Also, you can
enter an address in the input fields and it will show the path between those addresses. And there is a button that calls
a retractable side menu containing a button to go to the profile screen and a button responsible for exiting the
application (going to the start screen from the first item).

The third screen displays basic information about the user: username, email and avatar.

Before launch on iOS please make steps 4 and 5 from google_signin
instruction(https://pub.dev/packages/google_sign_in#ios-integration)
4.Open Xcode, then right-click on Runner directory and select Add Files to "Runner".
5.Select GoogleService-Info.plist from the file manager.
Because I don't have macbook and Xcode