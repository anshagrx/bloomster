package com.bloomster;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.*;
import java.util.Map;

public class ReadJSON {
    public Map<String, Object> readJSON(HttpServletRequest request) throws IOException {
        BufferedReader reader = request.getReader();
        StringBuilder jsonBuilder = new StringBuilder();
        String line;
        while((line = reader.readLine())!=null){
            jsonBuilder.append(line);
        }
        String jsonBody = jsonBuilder.toString();

        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> data = mapper.readValue(jsonBody, Map.class);
        return data;
    }
}
