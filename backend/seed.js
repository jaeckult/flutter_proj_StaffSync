const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();
const saltRounds = 10;

async function main() {
    // Delete all existing data to start fresh
    // await prisma.user.deleteMany();
    // // await prisma.leaveBalance.deleteMany();
    // await prisma.leaveRequest.deleteMany();
    // await prisma.attendance.deleteMany();
    // await prisma.blacklistedToken.deleteMany();
    // await prisma.profile.deleteMany();
    console.log('Deleted all existing records.');

    const users = [
        { 
            username: "alice", 
            email: 'alice@example.com', 
            password: 'password',
            profile: {
                fullName: "Alice Smith",
                gender: "FEMALE",
                employmentType: "PERMANENT",
                designation: "Team Lead",
                dateOfBirth: new Date("1985-05-10")
            }
        },
        { 
            username: "bob", 
            email: 'bob@example.com', 
            password: 'password',
            profile: {
                fullName: "Bob Johnson",
                gender: "MALE",
                employmentType: "CONTRACTUAL",
                designation: "Software Engineer",
                dateOfBirth: new Date("1990-08-15")
            }
        },
        { 
            username: "sam", 
            email: 'charlie@example.com', 
            password: 'password',
            profile: {
                fullName: "Sam Wilson",
                gender: "OTHER",
                employmentType: "INTERNSHIP",
                designation: "Intern",
                dateOfBirth: new Date("2000-01-20")
            }
        },
    ];

    // Insert users with initial points and create leave balances
    for (const user of users) {
        const createdUser = await prisma.user.create({
            data: {
                username: user.username,
                email: user.email,
                password: await bcrypt.hash(user.password, saltRounds),
                points: 100, // Initial points allocation
                profile: {
                    create: user.profile
                }
            },
        });
        console.log(`Created user: ${user.email}`);

        // Create initial leave balances for each leave type
        const leaveTypes = ['SICK', 'VACATION', 'PERSONAL'];
        for (const type of leaveTypes) {
            await prisma.leaveBalance.create({
                data: {
                    userId: createdUser.id,
                    type,
                    balance: 20, // Initial balance of 20 days per leave type
                },
            });
            console.log(`Created leave balance for ${type} for user: ${user.email}`);
        }
    }
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });