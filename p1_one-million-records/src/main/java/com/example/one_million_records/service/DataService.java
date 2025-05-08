package com.example.one_million_records.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;
import com.example.one_million_records.repository.DataRepository;
import com.example.one_million_records.entity.DataEntity;

@Service
public class DataService {
    private final DataRepository dataRepository;

    public DataService(DataRepository dataRepository) {
        this.dataRepository = dataRepository;
    }

    public Page<DataEntity> getData(int page, int size) {
        if (page < 0) {
            throw new IllegalArgumentException("Invalid page number");
        }
        return dataRepository.findAll(PageRequest.of(page, size));
    }
}