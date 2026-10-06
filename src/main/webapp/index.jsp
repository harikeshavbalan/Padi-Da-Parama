<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session != null && session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>
