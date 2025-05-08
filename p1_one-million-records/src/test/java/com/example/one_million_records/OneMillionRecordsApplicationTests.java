package com.example.one_million_records;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.mockito.Mockito.*;

import com.example.one_million_records.controller.DataController;
import com.example.one_million_records.entity.DataEntity;
import com.example.one_million_records.service.DataService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.test.web.servlet.MockMvc;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.util.List;

@WebMvcTest(DataController.class)
class OneMillionRecordsApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DataService dataService;

    private List<DataEntity> mockData;

    @BeforeEach
    void setUp() {
        mockData = List.of(
            new DataEntity(1L, "John Doe", 30, "john.doe@example.com"),
            new DataEntity(2L, "Jane Smith", 25, "jane.smith@example.com")
        );
    }

    @Test
    void contextLoads() {
        assertNotNull(mockMvc);
        assertNotNull(dataService);
    }

    @Test
    void testGetDataPagination() throws Exception {
        Page<DataEntity> mockPage = new PageImpl<>(mockData);
        when(dataService.getData(0, 2)).thenReturn(mockPage);

        mockMvc.perform(get("/api/data")
                .param("page", "0")
                .param("size", "2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.content.length()").value(2))
                .andExpect(jsonPath("$.content[0].name").value("John Doe"));
    }

    @Test
    void testGetDataInvalidPage() throws Exception {
        when(dataService.getData(-1, 2)).thenThrow(new IllegalArgumentException("Invalid page number"));

        mockMvc.perform(get("/api/data")
                .param("page", "-1")
                .param("size", "2"))
                .andExpect(status().isBadRequest());
    }
}
