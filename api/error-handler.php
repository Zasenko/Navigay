<?php

// отправляет ошибку -  не закрывая $stmt и $conn
function sendError($errorMessage)
{
    $json = ['result' => false, 'error' => ['show' => false, 'message' => $errorMessage]];
    echo json_encode($json);
    exit;
}

// отправляет ошибку пользователю -  не закрывая $stmt и $conn
function sendUserError($errorMessage)
{
    $json = ['result' => false, 'error' => ['show' => true, 'message' => $errorMessage]];
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}

// возвращает $stmt / в случае ошибки закрывает $stmt и $conn
function executeQuery($conn, $sql, $params, $types)
{
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        $error = $conn->error;
        $conn->close();
        sendError('Failed to prepare SQL statement: ' . $error);
    }
    $stmt->bind_param($types, ...$params);
    if (!$stmt->execute()) {
        $error = $stmt->error;
        $stmt->close();
        $conn->close();
        sendError('Execute error: ' . $error);
    }
    return $stmt;
}

// возвращает true и закрывает $stmt / в случае false закрывает $stmt и $conn
function checkInsertResult($stmt, $conn, $errorMessage)
{
    if ($stmt->affected_rows === 0) {
        $stmt->close();
        $conn->close();
        sendError($errorMessage);
    } else {
        $stmt->close();
        return true;
    }
}

// возвращает последний id / в случае null закрывает $conn
function getLastInsertId($conn)
{
    $lastInsertId = $conn->insert_id;

    if ($lastInsertId !== null) {
        return $lastInsertId;
    } else {
        $conn->close();
        sendError('Failed to retrieve the last insert ID.');
    }
}
