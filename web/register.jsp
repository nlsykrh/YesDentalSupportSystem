<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - Yes Dental</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
        }

        .overlay {
            min-height: 100vh;
            background: rgba(255, 255, 255, 0.40);
            backdrop-filter: blur(2px);
            display: flex;
            flex-direction: column;
        }

        .navbar-custom {
            padding: 18px 50px;
        }

        .logo {
            height: 55px;
            margin-right: 12px;
        }

        .clinic-title {
            font-size: 26px;
            font-weight: 700;
            color: #2f4a34;
            font-family: "Times New Roman", serif;
        }

        .page-wrap {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 30px 12px;
        }

        .reg-card {
            width: min(860px, 96%);
            background: linear-gradient(135deg, rgba(72, 110, 86, 0.97), rgba(52, 88, 66, 0.97));
            border-radius: 28px;
            padding: 42px 38px;
            color: white;
            box-shadow:
                0 25px 60px rgba(0, 0, 0, 0.35),
                0 10px 25px rgba(0, 0, 0, 0.25);
        }

        .reg-title {
            font-family: "Times New Roman", serif;
            font-size: 30px;
            font-weight: 800;
            text-align: center;
            margin-bottom: 6px;
        }

        .reg-sub {
            text-align: center;
            margin-bottom: 20px;
            opacity: 0.95;
        }

        .form-control,
        textarea.form-control {
            border-radius: 12px;
            border: none;
            padding: 11px;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.15);
        }

        .form-label {
            font-weight: 600;
        }

        .info-box {
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.20);
            padding: 14px;
            border-radius: 14px;
            font-size: 14px;
            margin-bottom: 20px;
            line-height: 1.5;
        }

        .btn-submit {
            background: white;
            color: #2f4a34;
            font-weight: 800;
            border-radius: 40px;
            padding: 10px 22px;
            border: none;
            width: 220px;
            display: block;
            margin: 0 auto;
            box-shadow:
                0 8px 18px rgba(0, 0, 0, 0.30),
                0 3px 8px rgba(0, 0, 0, 0.20);
            transition: all 0.25s ease;
        }

        .btn-submit:hover {
            background: #eef6f1;
            transform: translateY(-3px);
        }

        .bottom-link {
            text-align: center;
            margin-top: 18px;
            font-weight: 600;
        }

        .bottom-link a {
            color: white;
            text-decoration: underline;
        }
    </style>
</head>

<body>
    <div class="overlay">

        <!-- NAVBAR -->
        <nav class="navbar navbar-custom">
            <div class="d-flex align-items-center">
                <img src="<%=request.getContextPath()%>/images/Logo.png" class="logo" alt="Logo">
                <div class="clinic-title">Yes Dental Clinic</div>
            </div>
        </nav>

        <!-- CONTENT -->
        <div class="page-wrap">
            <div class="reg-card">

                <div class="reg-title">Create Patient Account</div>
                <div class="reg-sub">Please complete the form below to register.</div>

                <div class="info-box">
                    <strong>Important:</strong> Your first login password will be your
                    <strong>registered phone number</strong>.
                </div>

                <form id="registerForm"
                      action="<%=request.getContextPath()%>/RegisterServlet"
                      method="post"
                      novalidate>

                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="patient_status" value="A">

                    <div class="row g-3">

                        <div class="col-md-6">
                            <label class="form-label">Full Name</label>
                            <input type="text"
                                   class="form-control"
                                   name="patient_name"
                                   placeholder="e.g. Nur Aisyah Binti Ahmad"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">IC Number (12 digits)</label>
                            <input type="text"
                                   class="form-control"
                                   name="patient_ic"
                                   placeholder="e.g. 041023100460"
                                   pattern="\d{12}"
                                   title="IC must be exactly 12 digits (no dash)"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Phone Number</label>
                            <input type="tel"
                                   class="form-control"
                                   name="patient_phone"
                                   placeholder="e.g. 0123456789"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email"
                                   class="form-control"
                                   name="patient_email"
                                   placeholder="e.g. example@gmail.com"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Date of Birth</label>
                            <input type="date"
                                   class="form-control"
                                   name="patient_dob"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Guardian Contact Name</label>
                            <input type="text"
                                   class="form-control"
                                   name="patient_guardian"
                                   placeholder="e.g. Father / Mother / Spouse"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Guardian Contact Phone</label>
                            <input type="tel"
                                   class="form-control"
                                   name="patient_guardian_phone"
                                   placeholder="e.g. 0198765432"
                                   required>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Address</label>
                            <textarea class="form-control"
                                      name="patient_address"
                                      rows="2"
                                      placeholder="e.g. No 12, Jalan Seri Putra, Kajang"
                                      required></textarea>
                        </div>

                        <div class="col-12 mt-4 pt-2">
                            <button type="submit" class="btn btn-submit">Register</button>
                        </div>

                    </div>
                </form>

                <div class="bottom-link">
                    Already have account? <a href="login.jsp">Login Here</a>
                </div>

            </div>
        </div>

    </div>

    <!-- Validation Modal -->
    <div class="modal fade" id="validationModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Missing Information</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="validationMessage">
                    Please fill all required fields.
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        (function () {
            const form = document.getElementById("registerForm");
            const ic = document.querySelector('input[name="patient_ic"]');

            // IC: digits only + max 12
            if (ic) {
                ic.addEventListener("input", function () {
                    this.value = this.value.replace(/\D/g, "").slice(0, 12);
                });
            }

            // Popup validation
            form.addEventListener("submit", function (e) {
                if (!form.checkValidity()) {
                    e.preventDefault();

                    const firstInvalid = form.querySelector(":invalid");
                    const group = firstInvalid.closest(".col-md-6, .col-12");
                    const label = group ? group.querySelector(".form-label") : null;

                    document.getElementById("validationMessage").textContent =
                        "Please fill: " + (label ? label.textContent : "required fields");

                    new bootstrap.Modal(document.getElementById("validationModal")).show();
                }
            });
        })();
    </script>
</body>
</html>
