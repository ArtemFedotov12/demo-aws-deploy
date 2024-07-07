package com.example.demo.valiator;

import com.example.demo.GlobalDto;
import com.example.demo.service.SomeService;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CustomValidator implements ConstraintValidator<Custom, String> {

    private final SomeService someService;


    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (someService.text().length() != 4) {
            return false;
        }
        return value != null && value.length() > 2;
    }

}
