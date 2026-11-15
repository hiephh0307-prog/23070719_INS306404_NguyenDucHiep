<?php
// Contact Manager - List & Search Contacts
require_once __DIR__ . '/config.php';

$search = trim($_GET['search'] ?? '');
$group  = trim($_GET['group'] ?? '');

$sql    = 'SELECT * FROM contacts WHERE 1=1';
$params = [];

if ($search !== '') {
    $sql .= ' AND (name LIKE :s1 OR email LIKE :s2)';
    $params[':s1'] = '%' . $search . '%';
    $params[':s2'] = '%' . $search . '%';
}

if ($group !== '' && in_array($group, GROUPS, true)) {
    $sql .= ' AND group_name = :group';
    $params[':group'] = $group;
}

$sql .= ' ORDER BY created_at DESC, id DESC';

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$contacts = $stmt->fetchAll();

$flash = getFlash();
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Contact Manager</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <div class="top-head">
        <div>
            <h1>Contact Manager</h1>
            <div class="sub">Nguyen Duc Hiep (23070719) &middot; Total contacts: <strong><?= count($contacts) ?></strong></div>
        </div>
        <a href="add.php" class="btn">+ Add New Contact</a>
    </div>

    <?php if ($flash): ?>
        <div class="flash <?= htmlspecialchars($flash['type']) ?>"><?= htmlspecialchars($flash['msg']) ?></div>
    <?php endif; ?>

    <form method="get" action="index.php" class="search-bar">
        <input type="text" name="search" value="<?= htmlspecialchars($search) ?>" placeholder="Search by name or email...">
        <select name="group">
            <option value="">All Groups</option>
            <?php foreach (GROUPS as $g): ?>
                <option value="<?= $g ?>" <?= $group === $g ? 'selected' : '' ?>><?= $g ?></option>
            <?php endforeach; ?>
        </select>
        <button type="submit" class="btn">Search</button>
        <?php if ($search !== '' || $group !== ''): ?>
            <a href="index.php" class="btn btn-secondary">Clear</a>
        <?php endif; ?>
    </form>

    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Group</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($contacts)): ?>
                <tr><td colspan="6">No contacts found.</td></tr>
            <?php else: ?>
                <?php foreach ($contacts as $c): ?>
                    <tr>
                        <td><strong><?= htmlspecialchars($c['name']) ?></strong></td>
                        <td><?= htmlspecialchars($c['email']) ?></td>
                        <td><?= htmlspecialchars($c['phone']) ?></td>
                        <td><span class="badge"><?= htmlspecialchars($c['group_name']) ?></span></td>
                        <td><?= htmlspecialchars($c['created_at']) ?></td>
                        <td>
                            <a href="edit.php?id=<?= (int)$c['id'] ?>" class="btn btn-secondary btn-sm">Edit</a>
                            <a href="delete.php?id=<?= (int)$c['id'] ?>" class="btn btn-danger btn-sm">Delete</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>
</body>
</html>
