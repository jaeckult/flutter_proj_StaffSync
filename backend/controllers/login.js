const jwt = require('jsonwebtoken');
const loginRouter = require('express').Router();
const bcrypt = require('bcrypt');
const {PrismaClient} = require('@prisma/client');
const { identifyUser } = require('../utils/middleware');
const prisma = new PrismaClient();

loginRouter.post('/', async(req, res)=>{
    const {username, password} = req.body;
    
    if(!(username && password)){
        return res.status(401).json({
            error: "password or username field empty"
        });
    }
    try{
        const user = await prisma.user.findUnique({
            where: {username},
        });
        const correctPass = user===null?false :await bcrypt.compare(password, user.password);
    
        if(!(user && correctPass)){
            return res.status(400).json({
                error : 'username or password incorrect'
            });

        }


        const userToken = {
            username: user.username,
            id: user.id,
            role: user.role, 
           
          };
        console.log('userToken:', userToken);
        const token = jwt.sign(userToken, process.env.SECRET, { expiresIn: '1h' }); //this took me an hour to figure out, if you remove the expiration date, the logout doesn't work.
        res.status(201).send({
            token,
            username : user.username,
            email : user.email,
            role : user.role,
            id: user.id
       
        });
    
    
    
    } catch (error){
        console.error('error during login', error);
        res.status(500).json({error: 'internal server error during login'});
    } finally{
        await prisma.$disconnect();
    }

});

module.exports = loginRouter;