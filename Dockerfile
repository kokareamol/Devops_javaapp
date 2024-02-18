FROM openjdk:8
ADD jarstaging/com/valaxy/demo-workshop/2.1.2/demo-workshop-2.1.3.jar myapp.jar
ENTRYPOINT ["java", "-jar", "myapp.jar"]
