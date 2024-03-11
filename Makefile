b-native:
	./mvnw -Pnative native:compile

b-native-instrumented:
	./mvnw -Pinstrumented native:compile

b-native-monitored:
	./mvnw -Pmonitored native:compile

b-native-optimized:
	./mvnw -Poptimized native:compile

up-instrumented:
	./target/demo-instrumented

up-demo:
	./target/demo --enable-monitoring=heapdump,jfr,jvmstat

up-monitoring:
	./target/demo-monitored --enable-monitoring=heapdump,jfr,jvmstat

up-optimized:
	./target/demo-optimized

load-test:
	hey -n=1000 http://localhost:8080/hello