<?php
// Contact Manager - Delete Contact
require_once __DIR__ . '/config.php';

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id && (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST')) {
    $id = filter_input(INPUT_POST, 'id', FILTER_VALIDATE_INT);
}

$contact = null;
if ($id) {
    $stmt = $pdo->prepare('SELECT * FROM contacts WHERE id = :id');
    $stmt->execute([':id' => $id]);
    $contact = $stmt->fetch();
}

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    if ($contact) {
        $stmt = $pdo->prepare('DELETE FROM contacts WHERE id = :id');
        $stmt->execute([':id' => $id]);
        setFlash('success', 'Contact deleted successfully.');
    } else {
        setFlash('error', 'Contact not found.');
    }
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Delete Contact</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <div class="top-head">
        <h1>Delete Contact</h1>
        <a href="index.php" class="btn btn-secondary">&larr; Back to List</a>
    </div>

    <?php if (!$contact): ?>
        <div class="flash error">Contact not found.</div>
        <a href="index.php" class="btn">Back to List</a>
    <?php else: ?>
        <div class="confirm-box">
            <p><strong>Are you sure you want to delete this contact?</strong></p>
            <p>Name: <strong><?= htmlspecialchars($contact['name']) ?></strong></p>
            <p>Email: <?= htmlspecialchars($contact['email']) ?></p>
            <p>Phone: <?= htmlspecialchars($contact['phone']) ?></p>
            <p>Group: <?= htmlspecialchars($contact['group_name']) ?></p>
        </div>

        <form method="post" action="delete.php?id=<?= (int)$contact['id'] ?>">
            <input type="hidden" name="id" value="<?= (int)$contact['id'] ?>">
            <button type="submit" class="btn btn-danger">Confirm Delete</button>
            <a href="index.php" class="btn btn-secondary">Cancel</a>
        </form>
    <?php endif; ?>
</div>
</body>
</html>
