package com.example.demo;

import com.example.demo.valiator.Custom;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Getter
@Setter
public class GlobalDto {
    @Custom
    private String name;
}
