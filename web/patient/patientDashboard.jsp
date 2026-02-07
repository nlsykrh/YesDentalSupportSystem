<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String patientName = (String) session.getAttribute("patientName");
    String patientId = (String) session.getAttribute("patientId");

    if(patientName == null){
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Patient Dashboard - Yes Dental</title>

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Font Awesome -->
<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>

:root{
    --green-dark:#2f4a34;
    --green-deep:#264232;
}

/* ===== BODY ===== */
body{
    margin:0;
    min-height:100vh;
    background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
    background-size:cover;
    font-family:"Segoe UI",sans-serif;
}

.overlay{
    min-height:100vh;
    background:rgba(255,255,255,0.38);
    backdrop-filter:blur(1.5px);
}

/* ===== HEADER ===== */
.top-nav{
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:22px 60px 8px;
}

.brand{
    display:flex;
    align-items:center;
    gap:12px;
}

.brand img{ height:48px; }

.clinic-title{
    font-size:26px;
    font-weight:700;
    color:var(--green-dark);
    font-family:"Times New Roman", serif;
}

/* USER AREA */
.user-area{
    display:flex;
    align-items:center;
    gap:15px;
}

.user-chip{
    background:#f3f3f3;
    padding:6px 14px;
    border-radius:20px;
    font-size:13px;
    display:flex;
    align-items:center;
    gap:6px;
}

.logout-btn{
    background:#d96c6c;
    color:white;
    border:none;
    border-radius:40px;
    padding:7px 18px;
    font-weight:600;
    box-shadow:0 6px 14px rgba(0,0,0,0.2);
}

/* ===== LAYOUT ===== */
.layout-wrap{
    width:100%;
    padding:30px 60px 40px;
}

.layout{
    display:grid;
    grid-template-columns:280px 1fr;
    gap:24px;
}

/* ===== SIDEBAR ===== */
.sidebar{
    background:var(--green-deep);
    color:white;
    border-radius:14px;
    padding:20px 16px;
}

.sidebar h6{
    font-size:20px;
    margin-bottom:12px;
    padding-bottom:10px;
    border-bottom:1px solid rgba(255,255,255,0.25);
}

.side-link{
    display:flex;
    align-items:center;
    gap:10px;
    color:white;
    padding:9px 10px;
    border-radius:10px;
    text-decoration:none;
    font-size:14px;
    margin-bottom:6px;
}

.side-link i{
    width:18px;
    text-align:center;
}

.side-link:hover,
.side-link.active{
    background:rgba(255,255,255,0.14);
    color:#ffe69b;
}

/* ===== MAIN PANEL ===== */
.card-panel{
    background:rgba(255,255,255,0.92);
    border-radius:16px;
    padding:22px 24px 26px;
    box-shadow:0 14px 30px rgba(0,0,0,0.1);
}

/* HEADER TEXT */
.panel-header{
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:15px;
}

.panel-header h4{
    font-weight:700;
    margin:0;
}

/* ===== CAROUSEL ===== */
.carousel-wrap{
    background:white;
    border-radius:14px;
    border:1px solid #e6e6e6;
    padding:10px;
}

/* IMPORTANT → IMAGE FOLLOW ORIGINAL SIZE */
.carousel-item{
    text-align:center;
}

.carousel-item img{
    max-width:100%;
    height:auto;
    display:inline-block;
}

</style>
</head>

<body>

<div class="overlay">

<!-- HEADER -->
<div class="top-nav">

    <div class="brand">
        <img src="<%=request.getContextPath()%>/images/Logo.png">
        <div class="clinic-title">Yes Dental Clinic</div>
    </div>

    <div class="user-area">

        <div class="user-chip">
            <i class="fa fa-user"></i>
            <%= patientName %>
        </div>

        <form action="<%=request.getContextPath()%>/LogoutServlet" method="post">
            <button class="logout-btn">
                <i class="fa fa-right-from-bracket"></i> Logout
            </button>
        </form>

    </div>

</div>

<!-- MAIN -->
<div class="layout-wrap">
<div class="layout">

<!-- SIDEBAR -->
<div class="sidebar">

    <h6>Patient Dashboard</h6>

    <a class="side-link active"
       href="<%=request.getContextPath()%>/patient/patientDashboard.jsp">
        <i class="fa-solid fa-chart-line"></i> Dashboard
    </a>

    <a class="side-link"
       href="<%=request.getContextPath()%>/appointment/viewAppointment.jsp">
        <i class="fa-solid fa-calendar-check"></i> View Appointment
    </a>

    <a class="side-link"
       href="<%=request.getContextPath()%>/billing/viewBilling.jsp">
        <i class="fa-solid fa-file-invoice-dollar"></i> Billing
    </a>

    <a class="side-link"
       href="<%=request.getContextPath()%>/ProfileServlet">
        <i class="fa-solid fa-user"></i> My Profile
    </a>

</div>

<!-- CONTENT -->
<div class="card-panel">

    <div class="panel-header">

        <h4>
            Hi! <%= patientName %>
        </h4>

        <div style="font-size:13px;color:#666;">
            <i class="fa fa-id-card"></i>
            IC: <%= patientId %>
        </div>

    </div>

    <!-- CAROUSEL -->
    <div class="carousel-wrap">

        <div id="promoCarousel" class="carousel slide" data-bs-ride="carousel">

            <div class="carousel-inner">

                <div class="carousel-item active">
                    <img src="<%=request.getContextPath()%>/images/OfferTreatment.jpg" class="img-fluid">
                </div>

                <div class="carousel-item">
                    <img src="<%=request.getContextPath()%>/images/feedback.jpg" class="img-fluid">
                </div>

                <div class="carousel-item">
                    <img src="<%=request.getContextPath()%>/images/AboutUs.jpg" class="img-fluid">
                </div>

            </div>

            <button class="carousel-control-prev"
                    type="button"
                    data-bs-target="#promoCarousel"
                    data-bs-slide="prev">
                <span class="carousel-control-prev-icon"></span>
            </button>

            <button class="carousel-control-next"
                    type="button"
                    data-bs-target="#promoCarousel"
                    data-bs-slide="next">
                <span class="carousel-control-next-icon"></span>
            </button>

        </div>

    </div>

</div>

</div>
</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
