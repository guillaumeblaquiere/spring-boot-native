package main.java.com.example.demo;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SimpleController {
	@GetMapping("/")
	public ResponseEntity<?> hello() {
		return new ResponseEntity<>("hello world", HttpStatus.OK);
	}

	@GetMapping("/kill")
	public String kill() {
		System.exit(0);
		return "bye world";
	}
}