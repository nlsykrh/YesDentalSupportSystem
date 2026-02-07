<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login - Yes Dental</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body{
    margin:0;
    min-height:100vh;
    background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
    background-size:cover;
}

.overlay{
    min-height:100vh;
    background:rgba(255,255,255,0.40);
    backdrop-filter: blur(2px);
    display:flex;
    flex-direction:column;
}

.navbar-custom{ padding:18px 50px; }

.logo{ height:55px; margin-right:12px; }

.clinic-title{
    font-size:26px;
    font-weight:700;
    color:#2f4a34;
    font-family:"Times New Roman", serif;
}

.login-wrapper{
    flex:1;
    display:flex;
    justify-content:center;
    align-items:center;
}

.login-card{
    width:420px;
    background:linear-gradient(135deg, rgba(72,110,86,0.97), rgba(52,88,66,0.97));
    border-radius:28px;
    padding:45px 38px;
    color:white;

    box-shadow:
        0 25px 60px rgba(0,0,0,0.35),
        0 10px 25px rgba(0,0,0,0.25);

    transition:all 0.3s ease;
}

.login-card:hover{ transform:translateY(-4px); }

.login-title{
    font-family:"Times New Roman", serif;
    font-size:30px;
    font-weight:800;
    text-align:center;
    margin-bottom:28px;
}

.form-control{
    border-radius:12px;
    padding:11px;
    border:none;

    box-shadow:
        inset 0 2px 4px rgba(0,0,0,0.15),
        0 2px 6px rgba(0,0,0,0.10);

    transition:all 0.2s ease;
}

.form-control:focus{
    outline:none;
    box-shadow:
        inset 0 2px 4px rgba(0,0,0,0.15),
        0 0 0 3px rgba(47,74,52,0.25);
}

.form-label{ font-weight:600; }

.btn-login{
    background:white;
    color:#2f4a34;
    font-weight:800;
    border-radius:40px;
    padding:12px;
    border:none;
    width:100%;
    margin-top:12px;

    box-shadow:
        0 8px 18px rgba(0,0,0,0.30),
        0 3px 8px rgba(0,0,0,0.20);

    transition:all 0.25s ease;
}

.btn-login:hover{
    background:#eef6f1;
    transform:translateY(-3px) scale(1.02);
    box-shadow:
        0 16px 30px rgba(0,0,0,0.35),
        0 6px 12px rgba(0,0,0,0.25);
}

.error-box{
    background:#ffd6d6;
    color:#a10000;
    padding:10px;
    border-radius:10px;
    margin-bottom:18px;
    text-align:center;
    font-weight:600;
}

.register-link{
    text-align:center;
    margin-top:18px;
}

.register-link a{
    color:white;
    font-weight:700;
    text-decoration:underline;
}

.staff-note{
    display:none;
    margin-top:12px;
    font-size:13px;
    opacity:0.95;
    text-align:center;
}

@media(max-width:768px){
    .login-card{ width:92%; padding:38px 26px; }
}
</style>
</head>

<body>
<div class="overlay">

<nav class="navbar navbar-custom">
    <div class="d-flex align-items-center">
        <img src="<%=request.getContextPath()%>/images/Logo.png" class="logo">
        <div class="clinic-title">Yes Dental Clinic</div>
    </div>
</nav>

<div class="login-wrapper">
    <div class="login-card">

        <div class="login-title">Login To Yes Dental</div>

        <% if(request.getParameter("error") != null){ %>
            <div class="error-box">Invalid ID or Password</div>
        <% } %>

        <form action="LoginServlet" method="post">

            <!-- ROLE -->
            <div class="mb-3 text-center">
                <label class="me-3">
                    <input type="radio" name="userType" value="patient" checked>
                    Patient
                </label>

                <label>
                    <input type="radio" name="userType" value="staff">
                    Staff
                </label>
            </div>

            <!-- ID -->
            <div class="mb-3">
                <label class="form-label" id="userIdLabel">Patient IC</label>
                <input type="text"
                       id="userId"
                       name="userId"
                       class="form-control"
                       placeholder="e.g. 041023100460"
                       required>
            </div>

            <!-- PASSWORD -->
            <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password"
                       name="password"
                       class="form-control"
                       required>
            </div>

            <button type="submit" class="btn btn-login">Login</button>
        </form>

        <!-- Patient register only -->
        <div class="register-link" id="registerArea">
            New patient?
            <a href="register.jsp">Register Here</a>
        </div>


    </div>
</div>

</div>

<script>
(function(){
    const patientRadio = document.querySelector('input[name="userType"][value="patient"]');
    const staffRadio   = document.querySelector('input[name="userType"][value="staff"]');
    const userId       = document.getElementById("userId");
    const label        = document.getElementById("userIdLabel");
    const registerArea = document.getElementById("registerArea");
    const staffNote    = document.getElementById("staffNote");

    function setPatientMode(){
        label.textContent = "Patient IC";
        userId.placeholder = "e.g. 041023100460";
        userId.value = "";
        userId.setAttribute("pattern", "\\d{12}");
        userId.setAttribute("title", "IC must be exactly 12 digits (no dash).");

        registerArea.style.display = "block";
        staffNote.style.display = "none";
    }

    function setStaffMode(){
        label.textContent = "Staff ID";
        userId.placeholder = "e.g. STF001";
        userId.value = "";
        userId.removeAttribute("pattern");
        userId.removeAttribute("title");

        registerArea.style.display = "none";
        staffNote.style.display = "block";
    }

    patientRadio.addEventListener("change", setPatientMode);
    staffRadio.addEventListener("change", setStaffMode);

    // default
    setPatientMode();
})();
</script>

</body>
</html>
