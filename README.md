# flutter_proj_StaffSync


## Group Members

| Name              | ID.NO         | Section |  
|-------------------|--------------|----------|  
| Milki Legesse     | UGR/9040/15   | 2       |  
| Tesfanesh Asefa   | UGR/1233/15   | 2       |  
| Yitbarek Alemu    | UGR/7554/15   | 1       |  

📱 **StaffSync-Employee-Attendance-Leave-Manager**

StaffSync is a mobile application designed to streamline employee attendance tracking and leave management within an organization. The app empowers employees to easily check in for work and submit leave requests, while giving administrators full control over managing records in a secure and organized way.

The application features user authentication and role-based authorization, ensuring data privacy and appropriate access control. A RESTful backend supports all operations with complete CRUD functionality, and the system is thoroughly tested through unit, widget, and integration tests.

🔐 **Authentication & Authorization**

Authentication is required for all users to securely access the app using email and password.

Authorization is enforced based on user roles:

👤 **Roles**

**Employee**

Can log in and manage their own account

Can mark daily attendance

Can submit, edit, or cancel their own leave requests

Can view their personal attendance and leave history

**Manager**

Can log in and manage employee accounts within their team or department.

Can view, approve, reject, or modify leave requests from their team.

Can view and edit attendance records of employees in their team or department.

Can manage personal leave approvals and attendance records.


**Admin**

Can log in and manage all accounts

Can view, edit, or delete any employee’s attendance

Can view, approve, reject, or modify any leave request

Can manage employee profiles and role assignments

✅ **Key Features**

**Attendance Management (CRUD)**

Create:

Employees can mark their daily attendance.

Read:

Employees can view their attendance history.

Admins can view all employees' attendance records.

Update:

Admins can edit attendance records (e.g., fix mistakes).

Delete:

Admins can delete attendance records if needed.

**Leave Management (CRUD)**

Create:

Employees can submit leave requests.

Read:

Employees can view their own leave requests and balances.

Admins can view all leave requests.

Update:

Employees can edit their leave requests (before approval).

Admins can modify any leave request details.

Delete:

Employees can cancel their leave requests.

Admins can delete any leave request.
