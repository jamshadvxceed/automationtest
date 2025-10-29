import { spawn, ChildProcess } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';
import { logger } from '../utils/logger.js';

interface TestResult {
  success: boolean;
  output: string;
  duration?: number;
  exitCode?: number;
}

export class TestRunner {
  async runTest(
    projectPath: string,
    testFile: string,
    device?: string
  ): Promise<TestResult> {
    logger.info(`Running integration test: ${testFile}`);
    
    const startTime = Date.now();
    
    try {
      // 检查项目路径和测试文件是否存在
      if (!fs.existsSync(projectPath)) {
        throw new Error(`Flutter项目路径不存在: ${projectPath}`);
      }
      
      const fullTestPath = path.join(projectPath, testFile);
      if (!fs.existsSync(fullTestPath)) {
        throw new Error(`测试文件不存在: ${fullTestPath}`);
      }

      // 构建Flutter测试命令
      const command = this.buildTestCommand(testFile, device);
      const result = await this.executeFlutterCommand(command, projectPath);
      
      const duration = Date.now() - startTime;
      
      return {
        success: result.exitCode === 0,
        output: result.output,
        duration: duration,
        exitCode: result.exitCode
      };
      
    } catch (error) {
      const duration = Date.now() - startTime;
      logger.error('Test execution failed:', error);
      
      return {
        success: false,
        output: `测试执行失败: ${error instanceof Error ? error.message : String(error)}`,
        duration: duration,
        exitCode: -1
      };
    }
  }

  async runAllTests(projectPath: string, device?: string): Promise<TestResult> {
    logger.info('Running all integration tests');
    
    const command = device 
      ? ['test', 'integration_test', '-d', device]
      : ['test', 'integration_test'];
      
    const result = await this.executeFlutterCommand(command, projectPath);
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }

  async getAvailableDevices(): Promise<string[]> {
    try {
      const result = await this.executeFlutterCommand(['devices', '--machine'], process.cwd());
      
      if (result.exitCode === 0) {
        const devices = JSON.parse(result.output);
        return devices.map((device: any) => `${device.name} (${device.id})`);
      } else {
        logger.warn('Failed to get devices list');
        return [];
      }
    } catch (error) {
      logger.error('Error getting devices:', error);
      return [];
    }
  }

  async buildApp(projectPath: string, platform: 'android' | 'ios' = 'android'): Promise<TestResult> {
    logger.info(`Building app for ${platform}`);
    
    const command = platform === 'android' 
      ? ['build', 'apk', '--debug']
      : ['build', 'ios', '--debug', '--no-codesign'];
      
    const result = await this.executeFlutterCommand(command, projectPath);
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }

  async checkFlutterDoctor(): Promise<TestResult> {
    logger.info('Checking Flutter doctor');
    
    const result = await this.executeFlutterCommand(['doctor', '-v'], process.cwd());
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }

  private buildTestCommand(testFile: string, device?: string): string[] {
    const command = ['test', testFile];
    
    if (device) {
      command.push('-d', device);
    }
    
    return command;
  }

  private executeFlutterCommand(args: string[], workingDirectory: string): Promise<{
    output: string;
    exitCode: number;
  }> {
    return new Promise((resolve, reject) => {
      const flutter = spawn('flutter', args, {
        cwd: workingDirectory,
        stdio: ['ignore', 'pipe', 'pipe'],
        shell: true
      });

      let output = '';
      let errorOutput = '';

      flutter.stdout?.on('data', (data) => {
        const text = data.toString();
        output += text;
        logger.debug(`Flutter stdout: ${text.trim()}`);
      });

      flutter.stderr?.on('data', (data) => {
        const text = data.toString();
        errorOutput += text;
        logger.debug(`Flutter stderr: ${text.trim()}`);
      });

      flutter.on('close', (code) => {
        const fullOutput = output + (errorOutput ? `\\n\\nError Output:\\n${errorOutput}` : '');
        
        resolve({
          output: fullOutput,
          exitCode: code || 0
        });
      });

      flutter.on('error', (error) => {
        logger.error('Flutter command error:', error);
        reject(new Error(`Flutter命令执行失败: ${error.message}`));
      });

      // 设置超时
      setTimeout(() => {
        flutter.kill();
        reject(new Error('Flutter命令执行超时'));
      }, 300000); // 5分钟超时
    });
  }

  async installDependencies(projectPath: string): Promise<TestResult> {
    logger.info('Installing Flutter dependencies');
    
    const result = await this.executeFlutterCommand(['pub', 'get'], projectPath);
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }

  async cleanProject(projectPath: string): Promise<TestResult> {
    logger.info('Cleaning Flutter project');
    
    const result = await this.executeFlutterCommand(['clean'], projectPath);
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }

  async getTestCoverage(projectPath: string, testFile?: string): Promise<TestResult> {
    logger.info('Getting test coverage');
    
    const command = testFile 
      ? ['test', testFile, '--coverage']
      : ['test', 'integration_test', '--coverage'];
      
    const result = await this.executeFlutterCommand(command, projectPath);
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }

  async runTestsWithScreenshots(
    projectPath: string,
    testFile: string,
    device?: string
  ): Promise<TestResult> {
    logger.info(`Running test with screenshots: ${testFile}`);
    
    // 创建截图目录
    const screenshotDir = path.join(projectPath, 'integration_test', 'screenshots');
    if (!fs.existsSync(screenshotDir)) {
      fs.mkdirSync(screenshotDir, { recursive: true });
    }
    
    const command = this.buildTestCommand(testFile, device);
    command.push('--dart-define=SCREENSHOT_DIR=' + screenshotDir);
    
    const result = await this.executeFlutterCommand(command, projectPath);
    
    return {
      success: result.exitCode === 0,
      output: result.output,
      exitCode: result.exitCode
    };
  }
}