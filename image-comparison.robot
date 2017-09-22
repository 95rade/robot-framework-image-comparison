*** Settings ***
Resource    ./resources/image-comparison-keywords.robot


*** Test Cases ***
Image Comparison Ok
  Compare Images    ./reference-screenshots/reference-1.png    ./test-screenshots/test-1.png   0.1


Image Comparison NOk
  Compare Images    ./reference-screenshots/reference-2.png    ./test-screenshots/test-2.png   0.1
