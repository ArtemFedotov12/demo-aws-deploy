package com.example.demo.valiator;


import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = CustomValidator.class)
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface Custom {
    String message() default "name is too long";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
