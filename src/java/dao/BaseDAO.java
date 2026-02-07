package dao;

import java.util.List;

public interface BaseDAO<T> {
    boolean add(T obj);
    boolean update(T obj);
    boolean delete(int id);
    T getById(int id);
    List<T> getAllPatients();
}