package controllers;

import beans.Treatment;
import dao.TreatmentDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//@WebServlet("/TreatmentServlet")
public class TreatmentServlet extends HttpServlet {
    private TreatmentDAO treatmentDAO;
    
    @Override
    public void init() {
        treatmentDAO = new TreatmentDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addTreatment(request, response);
        } else if ("update".equals(action)) {
            updateTreatment(request, response);
        } else if ("delete".equals(action)) {
            deleteTreatment(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("edit".equals(action)) {
            editTreatment(request, response);
        } else if ("delete".equals(action)) {
            deleteTreatment(request, response);
        } else {
            // Default action: list treatments
            listTreatments(request, response);
        }
    }
    
    private void listTreatments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Treatment> treatments = treatmentDAO.getAllTreatments();
        request.setAttribute("treatments", treatments);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/treatment/viewTreatments.jsp");
        dispatcher.forward(request, response);
    }
    
    private void editTreatment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String treatmentId = request.getParameter("treatment_id");
        
        if (treatmentId == null || treatmentId.trim().isEmpty()) {
            request.setAttribute("error", "Treatment ID is required for editing.");
            listTreatments(request, response);
            return;
        }
        
        Treatment treatment = treatmentDAO.getTreatmentById(treatmentId);
        
        if (treatment == null) {
            request.setAttribute("error", "Treatment not found with ID: " + treatmentId);
            listTreatments(request, response);
            return;
        }
        
        request.setAttribute("treatment", treatment);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/treatment/editTreatment.jsp");
        dispatcher.forward(request, response);
    }
    
    private void addTreatment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            Treatment treatment = new Treatment();
            treatment.setTreatmentId(request.getParameter("treatment_id"));
            treatment.setTreatmentName(request.getParameter("treatment_name"));
            treatment.setTreatmentDesc(request.getParameter("treatment_desc"));
            treatment.setTreatmentPrice(Double.parseDouble(request.getParameter("treatment_price")));
            
            boolean success = treatmentDAO.add(treatment);
            
            if (success) {
                request.setAttribute("message", "Treatment added successfully!");
                listTreatments(request, response);
            } else {
                request.setAttribute("error", "Failed to add treatment. Treatment ID might already exist.");
                request.getRequestDispatcher("/treatment/addTreatment.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price format. Please enter a valid number.");
            request.getRequestDispatcher("/treatment/addTreatment.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/treatment/addTreatment.jsp").forward(request, response);
        }
    }
    
    private void updateTreatment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            Treatment treatment = new Treatment();
            treatment.setTreatmentId(request.getParameter("treatment_id"));
            treatment.setTreatmentName(request.getParameter("treatment_name"));
            treatment.setTreatmentDesc(request.getParameter("treatment_desc"));
            treatment.setTreatmentPrice(Double.parseDouble(request.getParameter("treatment_price")));
            
            boolean success = treatmentDAO.update(treatment);
            
            if (success) {
                request.setAttribute("message", "Treatment updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update treatment.");
            }
            
            listTreatments(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price format. Please enter a valid number.");
            editTreatment(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            editTreatment(request, response);
        }
    }
    
    private void deleteTreatment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String treatmentId = request.getParameter("treatment_id");
        boolean success = treatmentDAO.delete(treatmentId);
        
        if (success) {
            request.setAttribute("message", "Treatment deleted successfully!");
        } else {
            request.setAttribute("error", "Failed to delete treatment.");
        }
        
        listTreatments(request, response);
    }
}