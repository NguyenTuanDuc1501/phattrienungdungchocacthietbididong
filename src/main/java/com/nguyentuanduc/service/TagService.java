package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.nguyentuanduc.entity.Tag;
import com.nguyentuanduc.repository.TagRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TagService {

    private final TagRepository tagRepository;

    public List<Tag> getAllTags() {
        return tagRepository.findAll();
    }
}
