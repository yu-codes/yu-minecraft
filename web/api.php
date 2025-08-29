<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 處理 OPTIONS 請求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 腳本目錄路徑
$scriptsDir = realpath(__DIR__ . '/../../scripts');
$projectRoot = realpath(__DIR__ . '/../..');

// 允許的腳本列表（安全考量）
$allowedScripts = [
    'monitor' => 'monitor.sh',
    'backup' => 'backup.sh',
    'start' => 'start.sh',
    'stop' => 'stop.sh',
    'performance' => 'performance.sh',
    'plugins' => 'plugins.sh',
    'optimize' => 'optimize.sh'
];

// 獲取請求方法和路徑
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// 路由處理
function handleRequest($method, $pathParts) {
    global $allowedScripts, $scriptsDir, $projectRoot;
    
    if (count($pathParts) < 2 || $pathParts[0] !== 'api') {
        return ['error' => 'Invalid endpoint'];
    }
    
    $endpoint = $pathParts[1];
    
    switch ($endpoint) {
        case 'status':
            return getServerStatus();
            
        case 'execute':
            if ($method !== 'POST') {
                return ['error' => 'Method not allowed'];
            }
            $input = json_decode(file_get_contents('php://input'), true);
            $script = $input['script'] ?? '';
            $args = $input['args'] ?? [];
            return executeScript($script, $args);
            
        case 'logs':
            return getLogs();
            
        case 'files':
            $subpath = $pathParts[2] ?? '';
            return getFileList($subpath);
            
        default:
            return ['error' => 'Endpoint not found'];
    }
}

// 執行腳本函數
function executeScript($scriptName, $args = []) {
    global $allowedScripts, $scriptsDir, $projectRoot;
    
    if (!isset($allowedScripts[$scriptName])) {
        return ['success' => false, 'error' => 'Script not allowed'];
    }
    
    $scriptFile = $allowedScripts[$scriptName];
    $scriptPath = $scriptsDir . '/' . $scriptFile;
    
    if (!file_exists($scriptPath)) {
        return ['success' => false, 'error' => 'Script not found'];
    }
    
    // 構建命令
    $command = 'cd ' . escapeshellarg($projectRoot) . ' && bash ' . escapeshellarg($scriptPath);
    
    // 添加參數
    foreach ($args as $arg) {
        $command .= ' ' . escapeshellarg($arg);
    }
    
    // 執行命令
    $output = [];
    $returnCode = 0;
    exec($command . ' 2>&1', $output, $returnCode);
    
    return [
        'success' => $returnCode === 0,
        'output' => implode("\n", $output),
        'returnCode' => $returnCode
    ];
}

// 獲取伺服器狀態
function getServerStatus() {
    global $projectRoot;
    
    $status = [
        'timestamp' => date('Y-m-d H:i:s'),
        'docker_running' => false,
        'container_status' => 'unknown',
        'system_info' => []
    ];
    
    // 檢查 Docker 容器狀態
    $dockerCheck = 'cd ' . escapeshellarg($projectRoot . '/docker') . ' && docker compose ps 2>/dev/null';
    exec($dockerCheck, $dockerOutput, $dockerReturn);
    
    if ($dockerReturn === 0) {
        $dockerText = implode("\n", $dockerOutput);
        if (strpos($dockerText, 'Up') !== false) {
            $status['docker_running'] = true;
            $status['container_status'] = 'running';
        } else {
            $status['container_status'] = 'stopped';
        }
    }
    
    // 獲取系統資訊
    $status['system_info'] = [
        'uptime' => trim(shell_exec('uptime 2>/dev/null') ?: 'Unknown'),
        'disk_usage' => trim(shell_exec('df -h / 2>/dev/null | tail -1') ?: 'Unknown'),
        'memory_usage' => trim(shell_exec('free -h 2>/dev/null | head -2 | tail -1') ?: 'Unknown')
    ];
    
    return ['success' => true, 'data' => $status];
}

// 獲取日誌
function getLogs() {
    global $projectRoot;
    
    $logsDir = $projectRoot . '/logs';
    $logs = [];
    
    if (is_dir($logsDir)) {
        $files = glob($logsDir . '/*.log');
        foreach ($files as $file) {
            $content = file_get_contents($file);
            $logs[basename($file)] = array_slice(explode("\n", $content), -50); // 最後50行
        }
    }
    
    return ['success' => true, 'data' => $logs];
}

// 獲取檔案列表
function getFileList($subpath) {
    global $projectRoot;
    
    $allowedPaths = ['backups', 'plugins', 'logs'];
    
    if (!in_array($subpath, $allowedPaths)) {
        return ['error' => 'Path not allowed'];
    }
    
    $fullPath = $projectRoot . '/' . $subpath;
    $files = [];
    
    if (is_dir($fullPath)) {
        $scanFiles = scandir($fullPath);
        foreach ($scanFiles as $file) {
            if ($file !== '.' && $file !== '..') {
                $filePath = $fullPath . '/' . $file;
                $files[] = [
                    'name' => $file,
                    'size' => is_file($filePath) ? filesize($filePath) : 0,
                    'modified' => is_file($filePath) ? filemtime($filePath) : 0,
                    'type' => is_dir($filePath) ? 'directory' : 'file'
                ];
            }
        }
    }
    
    return ['success' => true, 'data' => $files];
}

// 主程序
try {
    $result = handleRequest($method, $pathParts);
    echo json_encode($result);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
