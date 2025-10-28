import * as fs from "fs/promises";
import * as path from "path";
import { glob } from "glob";
export class FlutterAnalyzer {
    async analyzeProject(projectPath) {
        const libPath = path.join(projectPath, "lib");
        try {
            await fs.access(libPath);
        }
        catch {
            throw new Error(`Invalid Flutter project path: ${projectPath}`);
        }
        // Find all Dart files
        const dartFiles = await glob("**/*.dart", { cwd: libPath });
        const screens = [];
        const routes = {};
        const controllers = [];
        const models = [];
        for (const file of dartFiles) {
            const fullPath = path.join(libPath, file);
            const content = await fs.readFile(fullPath, "utf-8");
            // Detect screens (files in views folder or containing Screen/Page)
            if (file.includes("views/") || file.includes("screens/") ||
                file.toLowerCase().includes("screen") || file.toLowerCase().includes("page")) {
                const screenInfo = await this.analyzeScreenContent(content, file);
                screens.push(screenInfo);
            }
            // Detect controllers
            if (file.includes("controller")) {
                controllers.push(file);
            }
            // Detect models
            if (file.includes("model")) {
                models.push(file);
            }
            // Extract routes
            if (content.includes("GetPage") || content.includes("routes")) {
                const extractedRoutes = this.extractRoutes(content);
                Object.assign(routes, extractedRoutes);
            }
        }
        return { screens, routes, controllers, models };
    }
    async analyzeScreen(projectPath, screenName) {
        const libPath = path.join(projectPath, "lib");
        const files = await glob(`**/*${screenName}*.dart`, { cwd: libPath, nocase: true });
        if (files.length === 0) {
            throw new Error(`Screen ${screenName} not found in project`);
        }
        const content = await fs.readFile(path.join(libPath, files[0]), "utf-8");
        return this.analyzeScreenContent(content, files[0]);
    }
    async analyzeScreenContent(content, filePath) {
        const name = path.basename(filePath, ".dart");
        // Extract widgets, text fields, buttons
        const widgets = this.extractWidgets(content);
        const textFields = this.extractTextFields(content);
        const buttons = this.extractButtons(content);
        const routes = this.extractNavigationCalls(content);
        const texts = this.extractTextContent(content);
        return {
            name,
            path: filePath,
            widgets,
            textFields,
            buttons,
            routes,
            texts,
        };
    }
    async analyzeWidgetFile(widgetPath) {
        const content = await fs.readFile(widgetPath, "utf-8");
        return {
            widgets: this.extractWidgets(content),
            textFields: this.extractTextFields(content),
            buttons: this.extractButtons(content),
            texts: this.extractTextContent(content),
            hasForm: content.includes('Form(') || content.includes('TextFormField'),
            hasNavigation: content.includes('Get.to') || content.includes('Navigator.'),
        };
    }
    extractWidgets(content) {
        const widgets = [];
        const widgetPattern = /\b([A-Z]\w+)\(/g;
        let match;
        while ((match = widgetPattern.exec(content)) !== null) {
            const widget = match[1];
            // Filter out common non-widget classes
            if (!['Get', 'Future', 'Stream', 'Duration', 'Color', 'Size'].includes(widget)) {
                if (!widgets.includes(widget)) {
                    widgets.push(widget);
                }
            }
        }
        return widgets;
    }
    extractTextFields(content) {
        const fields = [];
        const patterns = [
            'TextFormField',
            'TextField',
            'TextEditingController',
        ];
        patterns.forEach(pattern => {
            const count = (content.match(new RegExp(pattern, 'g')) || []).length;
            for (let i = 0; i < count; i++) {
                fields.push(pattern);
            }
        });
        return fields;
    }
    extractButtons(content) {
        const buttons = [];
        const buttonTypes = [
            'ElevatedButton',
            'TextButton',
            'OutlinedButton',
            'IconButton',
            'FloatingActionButton',
            'InkWell',
            'GestureDetector',
        ];
        buttonTypes.forEach(type => {
            const count = (content.match(new RegExp(type, 'g')) || []).length;
            for (let i = 0; i < count; i++) {
                buttons.push(type);
            }
        });
        return buttons;
    }
    extractTextContent(content) {
        const texts = [];
        const patterns = [
            /Text\s*\(\s*['"]([^'"]+)['"]\s*\)/g,
            /'([^']{3,})'/g,
            /"([^"]{3,})"/g,
        ];
        patterns.forEach(pattern => {
            let match;
            while ((match = pattern.exec(content)) !== null) {
                const text = match[1];
                if (text.length > 2 && !texts.includes(text) && !text.includes('\\')) {
                    texts.push(text);
                }
            }
        });
        return texts.slice(0, 20); // Limit to first 20
    }
    extractNavigationCalls(content) {
        const routes = [];
        const navPatterns = [
            /Get\.(to|toNamed|off|offNamed)\s*\(\s*([^)]+)\)/g,
            /Navigator\.(push|pushNamed)\s*\(\s*[^,]+,\s*([^)]+)\)/g,
        ];
        navPatterns.forEach(pattern => {
            let match;
            while ((match = pattern.exec(content)) !== null) {
                routes.push(match[2].trim());
            }
        });
        return routes;
    }
    extractRoutes(content) {
        const routes = {};
        const patterns = [
            /GetPage\s*\(\s*name:\s*['"]([^'"]+)['"]/g,
            /static\s+const\s+String\s+(\w+)\s*=\s*['"]([^'"]+)['"]/g,
        ];
        patterns.forEach(pattern => {
            let match;
            while ((match = pattern.exec(content)) !== null) {
                routes[match[1]] = match[2] || match[1];
            }
        });
        return routes;
    }
}
