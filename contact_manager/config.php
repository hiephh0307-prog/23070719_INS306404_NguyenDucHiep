<?php
// Database configuration - Nguyen Duc Hiep (23070719)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

const DB_HOST   = '127.0.0.1';
const DB_NAME   = 'contact_manager_db';
const DB_USER   = 'root';
const DB_PASS   = '';
const GROUPS    = ['Family', 'Friends', 'Work', 'Other'];

try {
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );
} catch (PDOException $e) {
    die('Database connection failed: ' . htmlspecialchars($e->getMessage()));
}

function setFlash(string $type, string $msg): void {
    $_SESSION['message']      = $msg;
    $_SESSION['message_type'] = $type;
}

function getFlash(): ?array {
    if (empty($_SESSION['message'])) {
        return null;
    }
    $flash = [
        'msg'  => $_SESSION['message'],
        'type' => $_SESSION['message_type'] ?? 'success',
    ];
    unset($_SESSION['message'], $_SESSION['message_type']);
    return $flash;
}
