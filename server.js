const express = require('express');
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Load OpenAPI specification
const swaggerDocument = YAML.load('./payroll-api.yaml');

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files (landing page)
app.use(express.static('public'));

// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument, {
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: "COBOL Payroll Calculator API"
}));

// Root endpoint - now serves the landing page from public/index.html

// Health check endpoint
app.get('/api/v1/health', (req, res) => {
    exec('cobc --version', (error, stdout) => {
        const cobolVersion = error ? 'Not installed' : stdout.split('\n')[0];
        res.json({
            status: 'healthy',
            cobolEngine: cobolVersion,
            timestamp: new Date().toISOString()
        });
    });
});

// Calculate payroll endpoint
app.post('/api/v1/calculate', async (req, res) => {
    try {
        const {
            employeeId,
            employeeName,
            hourlyRate,
            hoursWorked,
            state,
            filingStatus,
            allowances
        } = req.body;

        // Validate input
        if (!employeeId || !employeeName || !hourlyRate || !hoursWorked || !state || !filingStatus || allowances === undefined) {
            return res.status(400).json({
                error: 'Missing required fields',
                message: 'All fields are required for payroll calculation',
                timestamp: new Date().toISOString()
            });
        }

        // Create employee data file
        const employeeData = `${employeeId.padStart(5, '0')}${employeeName.padEnd(30)}${hourlyRate.toFixed(2).padStart(6, '0')}${hoursWorked.toFixed(2).padStart(6, '0')}${state}${filingStatus}${allowances}\n`;
        
        fs.writeFileSync('employee-data.dat', employeeData);

        // Execute COBOL program
        const startTime = Date.now();
        
        exec('./payroll', (error, stdout, stderr) => {
            if (error) {
                console.error('COBOL execution error:', error);
                return res.status(500).json({
                    error: 'COBOL processing error',
                    message: error.message,
                    timestamp: new Date().toISOString()
                });
            }

            const processingTime = ((Date.now() - startTime) / 1000).toFixed(3);

            // Parse the output file
            try {
                const reportContent = fs.readFileSync('payroll-report.txt', 'utf8');
                const payrollData = parsePayrollReport(reportContent);

                res.json({
                    employee: {
                        id: employeeId,
                        name: employeeName.trim()
                    },
                    payPeriod: 'WEEKLY',
                    earnings: payrollData.earnings,
                    deductions: payrollData.deductions,
                    netPay: payrollData.netPay,
                    calculationDetails: {
                        cobolVersion: 'GnuCOBOL 3.1.2',
                        processingTime: `${processingTime}s`,
                        precisionNote: 'Calculated using COBOL packed decimal arithmetic for exact precision'
                    }
                });
            } catch (parseError) {
                res.status(500).json({
                    error: 'Report parsing error',
                    message: parseError.message,
                    timestamp: new Date().toISOString()
                });
            }
        });
    } catch (err) {
        res.status(500).json({
            error: 'Server error',
            message: err.message,
            timestamp: new Date().toISOString()
        });
    }
});

// Batch processing endpoint
app.post('/api/v1/batch', async (req, res) => {
    try {
        const { employees } = req.body;
        
        if (!employees || !Array.isArray(employees)) {
            return res.status(400).json({
                error: 'Invalid request',
                message: 'Employees array is required',
                timestamp: new Date().toISOString()
            });
        }

        // Create batch employee data file
        let batchData = '';
        employees.forEach(emp => {
            batchData += `${emp.employeeId.padStart(5, '0')}${emp.employeeName.padEnd(30)}${emp.hourlyRate.toFixed(2).padStart(6, '0')}${emp.hoursWorked.toFixed(2).padStart(6, '0')}${emp.state}${emp.filingStatus}${emp.allowances}\n`;
        });
        
        fs.writeFileSync('employee-data.dat', batchData);

        const startTime = Date.now();
        
        exec('./payroll', (error, stdout, stderr) => {
            if (error) {
                return res.status(500).json({
                    error: 'COBOL processing error',
                    message: error.message,
                    timestamp: new Date().toISOString()
                });
            }

            const processingTime = ((Date.now() - startTime) / 1000).toFixed(3);
            
            res.json({
                results: [], // Would parse individual results here
                summary: {
                    totalEmployees: employees.length,
                    totalGrossPay: 0, // Would calculate from results
                    totalNetPay: 0, // Would calculate from results
                    processingTime: `${processingTime}s`
                }
            });
        });
    } catch (err) {
        res.status(500).json({
            error: 'Server error',
            message: err.message,
            timestamp: new Date().toISOString()
        });
    }
});

// Helper function to parse COBOL report output
function parsePayrollReport(reportContent) {
    const lines = reportContent.split('\n');
    const data = {
        earnings: {},
        deductions: {},
        netPay: 0
    };

    lines.forEach(line => {
        if (line.includes('Regular Hours:')) {
            const match = line.match(/(\d+\.\d+)\s*@\s*\$(\d+\.\d+)\s*=\s*\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.earnings.regularHours = parseFloat(match[1]);
                data.earnings.hourlyRate = parseFloat(match[2]);
                data.earnings.regularPay = parseFloat(match[3].replace(',', ''));
            }
        } else if (line.includes('Overtime Hours:')) {
            const match = line.match(/(\d+\.\d+).*=\s*\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.earnings.overtimeHours = parseFloat(match[1]);
                data.earnings.overtimePay = parseFloat(match[2].replace(',', ''));
            }
        } else if (line.includes('GROSS PAY:')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.earnings.grossPay = parseFloat(match[1].replace(',', ''));
            }
        } else if (line.includes('Federal Tax:')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.deductions.federalTax = parseFloat(match[1].replace(',', ''));
            }
        } else if (line.includes('State Tax')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.deductions.stateTax = parseFloat(match[1].replace(',', ''));
            }
        } else if (line.includes('Social Security:')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.deductions.socialSecurity = parseFloat(match[1].replace(',', ''));
            }
        } else if (line.includes('Medicare:')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.deductions.medicare = parseFloat(match[1].replace(',', ''));
            }
        } else if (line.includes('TOTAL DEDUCTIONS:')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.deductions.totalDeductions = parseFloat(match[1].replace(',', ''));
            }
        } else if (line.includes('NET PAY:')) {
            const match = line.match(/\$(\d+,?\d*\.\d+)/);
            if (match) {
                data.netPay = parseFloat(match[1].replace(',', ''));
            }
        }
    });

    return data;
}

// Start server
app.listen(PORT, () => {
    console.log(`COBOL Payroll API Server running on port ${PORT}`);
    console.log(`API Documentation: http://localhost:${PORT}/api-docs`);
    console.log(`Health Check: http://localhost:${PORT}/api/v1/health`);
});