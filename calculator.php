<?php
// Homework 9: Robust Calculator - Nguyen Duc Hiep (23070719)
error_reporting(E_ALL);
ini_set('display_errors', '0');

session_start();
date_default_timezone_set('Asia/Ho_Chi_Minh');

// Custom exception classes
class DivisionByZeroException extends Exception {}
class InvalidOperatorException extends Exception {}
class InvalidInputException extends Exception {}

if (!isset($_SESSION['history'])) {
    $_SESSION['history'] = [];
}

$num1     = '';
$operator = '+';
$num2     = '';
$output   = null;
$errorMsg = null;
$warnMsg  = null;

function writeErrorLog(string $type, string $message, string $inputStr): void {
    $ip   = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
    $line = sprintf("[%s] %s: %s | Input: \"%s\" | IP: %s\n", date('Y-m-d H:i:s'), $type, $message, $inputStr, $ip);
    file_put_contents(__DIR__ . '/calculator_errors.log', $line, FILE_APPEND);
}

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    if (isset($_POST['clear_history'])) {
        $_SESSION['history'] = [];
        $warnMsg = 'Calculation history cleared.';
    } else {
        $num1     = trim($_POST['num1'] ?? '');
        $operator = trim($_POST['operator'] ?? '+');
        $num2     = trim($_POST['num2'] ?? '');
        $inputStr = "$num1 $operator $num2";

        try {
            // 1. Validate numeric inputs
            if ($num1 === '' || $num2 === '' || !is_numeric($num1) || !is_numeric($num2)) {
                throw new InvalidInputException('Both inputs must be valid numbers.');
            }

            // 2. Validate operator
            $allowedOps = ['+', '-', '*', '/', '%', '**'];
            if (!in_array($operator, $allowedOps, true)) {
                throw new InvalidOperatorException("Unsupported operator '$operator'.");
            }

            $a = (float)$num1;
            $b = (float)$num2;

            // 3. Check division or modulo by zero
            if (($operator === '/' || $operator === '%') && $b == 0.0) {
                $opLabel = $operator === '/' ? 'Division' : 'Modulo';
                throw new DivisionByZeroException("$opLabel by zero is not allowed.");
            }

            // 4. Calculate result
            if ($operator === '**' && abs($a) > 1 && $b > 1024) {
                throw new OverflowException('Result exceeds PHP floating-point limits.');
            }

            $res = match ($operator) {
                '+'  => $a + $b,
                '-'  => $a - $b,
                '*'  => $a * $b,
                '/'  => $a / $b,
                '%'  => fmod($a, $b),
                '**' => $a ** $b,
            };

            if (is_infinite($res) || is_nan($res)) {
                throw new OverflowException('Result exceeds PHP floating-point limits.');
            }

            // Format output: 4 decimals for division, integer/clean number for others
            if ($operator === '/') {
                $formatted = number_format($res, 4, '.', '');
            } elseif (floor($res) == $res && abs($res) < PHP_INT_MAX) {
                $formatted = (string)(int)$res;
            } else {
                $formatted = (string)round($res, 4);
            }

            $output = "$num1 $operator $num2 = $formatted";

            array_unshift($_SESSION['history'], [
                'expression' => "$num1 $operator $num2",
                'result'     => $formatted,
                'timestamp'  => date('Y-m-d H:i:s'),
            ]);
        } catch (InvalidInputException $e) {
            $errorMsg = $e->getMessage();
            writeErrorLog('InvalidInputException', $errorMsg, $inputStr);
        } catch (InvalidOperatorException $e) {
            $errorMsg = $e->getMessage();
            writeErrorLog('InvalidOperatorException', $errorMsg, $inputStr);
        } catch (DivisionByZeroException $e) {
            $errorMsg = $e->getMessage();
            writeErrorLog('DivisionByZeroException', $errorMsg, $inputStr);
        } catch (OverflowException $e) {
            $errorMsg = $e->getMessage();
            writeErrorLog('OverflowException', $errorMsg, $inputStr);
        } catch (Exception $e) {
            $errorMsg = 'An unexpected error occurred.';
            writeErrorLog('Exception', $e->getMessage(), $inputStr);
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Calculator - Homework 9</title>
<style>
body { margin: 0; font-family: "Segoe UI", Arial, sans-serif; background: #f4f6f9; color: #222; padding: 28px 16px; }
.container { max-width: 680px; margin: 0 auto; background: #fff; border: 1px solid #dde2e8; border-radius: 8px; padding: 24px 28px; }
h1 { margin: 0 0 6px; color: #1e3a5f; font-size: 24px; }
.sub { margin: 0 0 20px; color: #666; font-size: 14px; }
.form-row { display: grid; grid-template-columns: 1fr 90px 1fr; gap: 12px; margin-bottom: 16px; }
label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; }
input[type="text"], select { width: 100%; padding: 8px 10px; border: 1px solid #ccd2da; border-radius: 4px; font: inherit; box-sizing: border-box; }
.buttons { display: flex; gap: 10px; margin-bottom: 20px; }
.btn { background: #1e3a5f; color: #fff; border: none; padding: 9px 18px; border-radius: 4px; font: inherit; cursor: pointer; }
.btn-clear { background: #6c757d; }
.alert { padding: 12px 16px; border-radius: 4px; margin-bottom: 20px; font-size: 15px; }
.alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; font-weight: 600; }
.alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
.alert-warn { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
h2 { font-size: 18px; color: #1e3a5f; margin: 24px 0 10px; }
table { width: 100%; border-collapse: collapse; font-size: 14px; }
th, td { padding: 9px 12px; border-bottom: 1px solid #e4e8ee; text-align: left; }
th { background: #f1f4f8; font-weight: 600; }
@media (max-width: 520px) { .form-row { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<div class="container">
    <h1>Robust Calculator</h1>
    <p class="sub">Nguyen Duc Hiep (23070719) &middot; Class INS306404</p>

    <?php if ($output !== null): ?>
        <div class="alert alert-success"><?= htmlspecialchars($output) ?></div>
    <?php endif; ?>

    <?php if ($errorMsg !== null): ?>
        <div class="alert alert-error"><strong>Error:</strong> <?= htmlspecialchars($errorMsg) ?></div>
    <?php endif; ?>

    <?php if ($warnMsg !== null): ?>
        <div class="alert alert-warn"><?= htmlspecialchars($warnMsg) ?></div>
    <?php endif; ?>

    <form method="post" action="calculator.php">
        <div class="form-row">
            <div>
                <label for="num1">First Number</label>
                <input type="text" id="num1" name="num1" value="<?= htmlspecialchars($num1) ?>" placeholder="e.g. 10">
            </div>
            <div>
                <label for="operator">Operator</label>
                <select id="operator" name="operator">
                    <?php foreach (['+', '-', '*', '/', '%', '**'] as $op): ?>
                        <option value="<?= $op ?>" <?= $operator === $op ? 'selected' : '' ?>><?= $op ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div>
                <label for="num2">Second Number</label>
                <input type="text" id="num2" name="num2" value="<?= htmlspecialchars($num2) ?>" placeholder="e.g. 3">
            </div>
        </div>

        <div class="buttons">
            <button type="submit" name="calculate" class="btn">Calculate</button>
            <button type="submit" name="clear_history" value="1" class="btn btn-clear">Clear History</button>
        </div>
    </form>

    <h2>Calculation History</h2>
    <?php if (empty($_SESSION['history'])): ?>
        <p style="color:#666;font-size:14px;">No calculations yet.</p>
    <?php else: ?>
        <table>
            <thead>
                <tr>
                    <th>Expression</th>
                    <th>Result</th>
                    <th>Time</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($_SESSION['history'] as $item): ?>
                    <tr>
                        <td><?= htmlspecialchars($item['expression']) ?></td>
                        <td><strong><?= htmlspecialchars($item['result']) ?></strong></td>
                        <td><?= htmlspecialchars($item['timestamp']) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>
</div>
</body>
</html>
