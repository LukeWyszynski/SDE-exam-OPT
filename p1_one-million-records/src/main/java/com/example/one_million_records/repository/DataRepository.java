package com.example.one_million_records.repository;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;
import com.example.one_million_records.entity.DataEntity;

@Repository
public interface DataRepository extends JpaRepository<DataEntity, Long> {
    // no additional query methods needed;
    // basic CRUD operations and pagination are provided
}