package controllers;

import dao.AppointmentDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AvailabilityServlet")
public class AvailabilityServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        AppointmentDAO dao = new AppointmentDAO();
        String action = request.getParameter("action");

        // Fully booked dates for a month: /AvailabilityServlet?action=fullyBooked&month=YYYY-MM
        if ("fullyBooked".equalsIgnoreCase(action)) {
            String month = request.getParameter("month");
            if (month == null || month.trim().isEmpty()) {
                response.getWriter().write("[]");
                return;
            }
            List<String> dates = dao.getFullyBookedDates(month);
            writeJsonArray(response, dates);
            return;
        }

        // Default: booked times for a date: /AvailabilityServlet?date=YYYY-MM-DD
        String date = request.getParameter("date");
        if (date == null || date.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        List<String> times = dao.getBookedTimesConfirmed(date);
        writeJsonArray(response, times);
    }

    private void writeJsonArray(HttpServletResponse response, List<String> items) throws IOException {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < items.size(); i++) {
            sb.append("\"").append(items.get(i)).append("\"");
            if (i < items.size() - 1) sb.append(",");
        }
        sb.append("]");
        response.getWriter().write(sb.toString());
    }
}
