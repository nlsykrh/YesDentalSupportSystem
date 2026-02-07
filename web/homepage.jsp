<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Yes Dental Clinic</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

/* ===== BACKGROUND ===== */
body{
    margin:0;
    min-height:100vh;
    background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
    background-size:cover;
}

.overlay{
    min-height:100vh;
    background:rgba(255,255,255,0.32);
    backdrop-filter: blur(1.5px);
    display:flex;
    flex-direction:column;
}

/* ===== NAVBAR ===== */
.navbar-custom{ padding:22px 60px; }

.logo{ height:62px; margin-right:15px; }

.clinic-title{
    font-size:30px;
    font-weight:700;
    color:#2f4a34;
    font-family:"Times New Roman", serif;
}

/* ===== MAIN ===== */
.main-section{
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding-left:4%;
    padding-right:8%;
}

/* ===== HERO TEXT ===== */
.hero-text{
    font-family:"Times New Roman", serif;
    color:#2f4a34;
    font-size:68px;
    font-weight:700;
    line-height:1.1;
    text-shadow:0 6px 18px rgba(0,0,0,0.18);
    margin-left:-25px;
}

/* ===== CARD ===== */
.welcome-card{
    font-family:Arial, Helvetica, sans-serif;

    background:linear-gradient(
        135deg,
        rgba(72,110,86,0.92),
        rgba(52,88,66,0.92)
    );

    border-radius:28px;
    padding:56px 50px;
    width:430px;

    color:white;
    text-align:center;

    box-shadow:0 22px 55px rgba(0,0,0,0.18);
}

/* ===== TITLE SAME SIZE BOLD CENTER ===== */
.title-box{
    max-width:360px;
    margin:0 auto 22px auto;
}

.title-box div{
    font-size:30px;       /* SAME SIZE ALL */
    font-weight:800;      /* BOLD */
    text-align:center;
    margin:6px 0;
}

/* ===== TEXT ===== */
.welcome-card p{
    font-size:16px;
    opacity:0.95;
    margin-bottom:24px;
}

/* ===== BUTTON ===== */
.start-btn{
    background:white;
    color:#2f4a34;
    border-radius:40px;
    padding:14px 48px;
    font-weight:700;
    border:none;

    box-shadow:
        0 8px 18px rgba(0,0,0,0.25),
        0 2px 4px rgba(0,0,0,0.15);

    transition:all 0.25s ease;
}

.start-btn:hover{
    transform:translateY(-3px) scale(1.02);
    background:#eef6f1;

    box-shadow:
        0 14px 28px rgba(0,0,0,0.30),
        0 6px 10px rgba(0,0,0,0.20);
}

/* ===== MOBILE ===== */
@media(max-width:992px){
    .main-section{
        flex-direction:column;
        text-align:center;
        gap:30px;
        padding-left:0;
        padding-right:0;
    }

    .hero-text{
        font-size:48px;
        margin-left:0;
    }

    .welcome-card{
        width:92%;
        padding:46px 28px;
    }
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

<div class="container flex-grow-1 main-section">

    <div class="hero-text">
        Good vibes <br>
        start with <br>
        good smiles.
    </div>

    <div class="welcome-card">

        <div class="title-box">
            <div>Welcome To</div>
            <div>Yes Dental Appointment</div>
            <div>System</div>
        </div>

        <p>Click below to begin</p>

        <a href="login.jsp" class="btn start-btn">Start Now</a>

    </div>

</div>

</div>

</body>
</html>
