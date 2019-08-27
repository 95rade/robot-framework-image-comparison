# robot-framework-image-comparison

See https://blog.codecentric.de/en/2017/09/robot-framework-compare-images-screenshots/ for details.

Implementing the “Compare Images” Keyword

The implementation of this keyword is based on the possibility to execute a system command and retrieve its output using the “Run And Return Rc And Output” keyword from the Robot Framework OperatingSystem library. Thus we can execute the ImageMagick compare command and retrieve the distortion %-value. That value is then used to decide whether or not the comparison is considered successful or not.

    The complete example can be found from GitHub: https://github.com/ThomasJaspers/robot-framework-image-comparison.

The following listing shows the implementation of the keyword. The keyword is implemented in a separate resource file that can be used in one’s own projects right away (aside from adjustments depending on the used operating system).

*** Settings ***
Library   String
Library   OperatingSystem

*** Variables ***
${IMAGE_COMPARATOR_COMMAND}   /usr/local/Cellar/imagemagick/7.0.7-3/bin/convert __REFERENCE__ __TEST__ -metric RMSE -compare -format  "%[distortion]" info:

*** Keywords ***
Compare Images
   [Arguments]      ${Reference_Image_Path}    ${Test_Image_Path}    ${Allowed_Threshold}
   ${TEMP}=         Replace String     ${IMAGE_COMPARATOR_COMMAND}    __REFERENCE__     ${Reference_Image_Path}
   ${COMMAND}=      Replace String     ${TEMP}    __TEST__     ${Test_Image_Path}
   Log              Executing: ${COMMAND}
   ${RC}            ${OUTPUT}=     Run And Return Rc And Output     ${COMMAND}
   Log              Return Code: ${RC}
   Log              Return Output: ${OUTPUT}
   ${RESULT}        Evaluate    ${OUTPUT} < ${Allowed_Threshold}
   Should be True   ${RESULT}

The variable ${IMAGE_COMPARATOR_COMMAND} defines the command to be executed for the image comparison. It contains placeholders for the concrete path information to the images to be compared. Those are replaced in the command string with the path values given as parameters and the resulting command string is logged out for troubleshooting purposes.

    This approach should allow to easily adept this keyword for other operating systems. The idea is that only the command defined in ${IMAGE_COMPARATOR_COMMAND} needs to be changed to fit the underlying operating system.

The command is then executed and the resulting value indicating the differences is compared with the given threshold. That threshold is also given as a parameter and defines the grade of deviation that is considered ok. If that value is exceeded the keyword will fail and thus a corresponding test case. For troubleshooting purposes the return code and output of the system call is logged out to the Robot Framework log.html.

The test cases are defined as shown below. The images used are created in a way that the first test will succeed and the second test will fail (as seen in the screenshot of the log.html above).

*** Settings ***
Resource    ./resources/image-comparison-keywords.robot

*** Test Cases ***
Image Comparison Ok
  Compare Images    ./reference-screenshots/reference-1.png    ./test-screenshots/test-1.png   0.1

Image Comparison NOk
  Compare Images    ./reference-screenshots/reference-2.png    ./test-screenshots/test-2.png   0.1

The threshold value is definitely something to play around with in a real-life test scenario. It might make sense to set it to 0.0 and thus completely strict. Of course the reference images must be created the same way (same size, same detail) as the images to be tested. In a scenario using Selenium this would mean to have a run taking the reference screenshots first. Those screenshots must be checked manually and then stored to the reference-screenshots directory. When making screenshots with Selenium it is possible to define the name for those screenshots and thus it should be no problem to trigger the comparison then as shown above in subsequent test runs.
Conclusion

The approach described in this document is hopefully helpful for projects considering image comparison as part of their test automation using the Robot Framework. The quality of the results of course strongly depends on the quality of the image comparison of the used tool – in this case ImageMagick. I do not really have any experience with this, but at least while developing this playground project it worked as expected. Having this example at hand, it might be possible to implement a prototype for these kinds of tests relatively quickly.

Any real-life feedback is of course very welcome :-).
