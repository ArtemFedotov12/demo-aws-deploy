package com.example.demo;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Validated
public class TestController {

    @GetMapping("/test")
    String test() {
        return "some3";
    }

    @PostMapping("/dto")
    ResponseEntity<?> some(@RequestBody @Valid GlobalDto dto) {
        return ResponseEntity.ok( dto.getName());
    }

}
