<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - YesDental</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            width: 400px;
        }
        h2 {
            color: #2c3e50;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: bold;
        }
        input[type="text"],
        input[type="password"],
        input[type="email"],
        input[type="tel"],
        input[type="date"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .radio-group {
            display: flex;
            gap: 20px;
            margin: 15px 0;
        }
        .radio-group label {
            display: flex;
            align-items: center;
            font-weight: normal;
        }
        .btn {
            width: 100%;
            padding: 12px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        .btn:hover {
            background-color: #2980b9;
        }
        .login-link {
            text-align: center;
            margin-top: 20px;
        }
        .error {
            color: #e74c3c;
            background-color: #fadbd8;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Create Patient Account</h2>
        
        <div id="errorMessage" class="error"></div>
        
        <form action="${pageContext.request.contextPath}/RegisterServlet" method="post">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="patient_crdate" value="<%= new java.sql.Timestamp(System.currentTimeMillis()) %>">
            <input type="hidden" name="patient_status" value="A">
            <input type="hidden" name="patient_password">
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Full Name</label>
                    <input type="text" class="form-control" name="patient_name" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">IC Number</label>
                    <input type="text" class="form-control" name="patient_ic" required>
                </div>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Phone</label>
                    <input type="tel" class="form-control" name="patient_phone" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" name="patient_email" required>
                </div>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Date of Birth</label>
                    <input type="date" class="form-control" name="patient_dob" required>
                </div>
                <div class="mb-3">
                <label class="form-label">Address</label>
                <textarea class="form-control" name="patient_address" rows="2" required></textarea>
                </div>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Guardian's Name</label>
                <textarea class="form-control" name="patient_guardian" rows="3"></textarea>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Guardian's Phone</label>
                <textarea class="form-control" name="patient_guardian_phone" rows="3"></textarea>
            </div>
            
            <div class="d-flex justify-content-between">
                <!--<a href="viewPatients.jsp" class="btn btn-secondary">← Back to Patients</a>-->
                <button type="submit" class="btn btn-primary">Add Patient</button>
            </div>
        </form>
        
        <div class="login-link">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </div>
    
    <script>
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const password = document.getElementById('patient_password').value;
            const confirmPassword = prompt("Please confirm your password:");
            
            if (password !== confirmPassword) {
                e.preventDefault();
                document.getElementById('errorMessage').style.display = 'block';
                document.getElementById('errorMessage').textContent = 'Passwords do not match!';
            }
        });
    </script>
</body>
</html>