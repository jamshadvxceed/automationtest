export interface ScreenInfo {
    name: string;
    path: string;
    widgets: string[];
    textFields: string[];
    buttons: string[];
    routes: string[];
    texts: string[];
}
export interface ProjectAnalysis {
    screens: ScreenInfo[];
    routes: Record<string, string>;
    controllers: string[];
    models: string[];
}
export declare class FlutterAnalyzer {
    analyzeProject(projectPath: string): Promise<ProjectAnalysis>;
    analyzeScreen(projectPath: string, screenName: string): Promise<ScreenInfo>;
    private analyzeScreenContent;
    analyzeWidgetFile(widgetPath: string): Promise<any>;
    private extractWidgets;
    private extractTextFields;
    private extractButtons;
    private extractTextContent;
    private extractNavigationCalls;
    private extractRoutes;
}
