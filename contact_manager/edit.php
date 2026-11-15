<?php
// Contact Manager - Edit Contact
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

$errors    = [];
$name      = $contact['name'] ?? '';
$email     = $contact['email'] ?? '';
$phone     = $contact['phone'] ?? '';
$groupName = $contact['group_name'] ?? 'Other';
$notes     = (string)($contact['notes'] ?? '');

if ($contact && (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST')) {
    $name      = trim($_POST['name'] ?? '');
    $email     = trim($_POST['email'] ?? '');
    $phone     = trim($_POST['phone'] ?? '');
    $groupName = trim($_POST['group_name'] ?? 'Other');
    $notes     = trim($_POST['notes'] ?? '');

    if ($name === '') {
        $errors['name'] = 'Name cannot be empty.';
    }

    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = 'Please enter a valid email address.';
    } else {
        $stmt = $pdo->prepare('SELECT id FROM contacts WHERE email = :email AND id != :id');
        $stmt->execute([':email' => $email, ':id' => $id]);
        if ($stmt->fetch()) {
            $errors['email'] = 'This email is already in use by another contact.';
        }
    }

    if ($phone === '' || !preg_match('/^[0-9+\-\s()]{8,20}$/', $phone)) {
        $errors['phone'] = 'Please enter a valid phone number (8-20 digits).';
    }

    if (!in_array($groupName, GROUPS, true)) {
        $errors['group_name'] = 'Invalid group selected.';
    }

    if (empty($errors)) {
        try {
            $stmt = $pdo->prepare(
                'UPDATE contacts
                 SET name = :name, email = :email, phone = :phone, group_name = :group_name, notes = :notes
                 WHERE id = :id'
            );
            $stmt->execute([
                ':name'       => $name,
                ':email'      => $email,
                ':phone'      => $phone,
                ':group_name' => $groupName,
                ':notes'      => $notes !== '' ? $notes : null,
                ':id'         => $id,
            ]);

            setFlash('success', 'Contact updated successfully!');
            header('Location: index.php');
            exit;
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                $errors['email'] = 'This email is already in use.';
            } else {
                $errors['general'] = 'Could not update contact.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Contact</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <div class="top-head">
        <h1>Edit Contact</h1>
        <a href="index.php" class="btn btn-secondary">&larr; Back to List</a>
    </div>

    <?php if (!$contact): ?>
        <div class="flash error">Contact not found.</div>
        <a href="index.php" class="btn">Back to List</a>
    <?php else: ?>
        <?php if (isset($errors['general'])): ?>
            <div class="flash error"><?= htmlspecialchars($errors['general']) ?></div>
        <?php endif; ?>

        <form method="post" action="edit.php?id=<?= (int)$contact['id'] ?>" novalidate>
            <input type="hidden" name="id" value="<?= (int)$contact['id'] ?>">

            <div class="field">
                <label for="name">Name *</label>
                <input type="text" id="name" name="name" value="<?= htmlspecialchars($name) ?>" required>
                <?php if (isset($errors['name'])): ?><span class="error"><?= htmlspecialchars($errors['name']) ?></span><?php endif; ?>
            </div>

            <div class="field">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email" value="<?= htmlspecialchars($email) ?>" required>
                <?php if (isset($errors['email'])): ?><span class="error"><?= htmlspecialchars($errors['email']) ?></span><?php endif; ?>
            </div>

            <div class="field">
                <label for="phone">Phone *</label>
                <input type="text" id="phone" name="phone" value="<?= htmlspecialchars($phone) ?>" required>
                <?php if (isset($errors['phone'])): ?><span class="error"><?= htmlspecialchars($errors['phone']) ?></span><?php endif; ?>
            </div>

            <div class="field">
                <label for="group_name">Group</label>
                <select id="group_name" name="group_name">
                    <?php foreach (GROUPS as $g): ?>
                        <option value="<?= $g ?>" <?= $groupName === $g ? 'selected' : '' ?>><?= $g ?></option>
                    <?php endforeach; ?>
                </select>
                <?php if (isset($errors['group_name'])): ?><span class="error"><?= htmlspecialchars($errors['group_name']) ?></span><?php endif; ?>
            </div>

            <div class="field">
                <label for="notes">Notes</label>
                <textarea id="notes" name="notes" rows="3"><?= htmlspecialchars($notes) ?></textarea>
            </div>

            <button type="submit" class="btn">Update Contact</button>
        </form>
    <?php endif; ?>
</div>
</body>
</html>
