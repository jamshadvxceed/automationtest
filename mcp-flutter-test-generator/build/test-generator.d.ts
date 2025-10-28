export interface TestGenerationOptions {
    screenName: string;
    testType: string;
    scenario?: string;
    screenAnalysis: any;
}
export declare class TestGenerator {
    generateTest(options: TestGenerationOptions): Promise<string>;
    private generateAuthTest;
    private generateFormTest;
    private generateNavigationTest;
    private generateCustomTest;
    private generateScreenVerification;
    private generateTextFieldInteractions;
    private generateButtonTap;
    generateTestSuite(analysis: any, coverage: string): Promise<any>;
    private determineTestType;
}
