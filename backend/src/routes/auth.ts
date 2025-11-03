import { Router, Request, Response } from "express";
import { db } from "../db/indexdb.js";
import { NewUser, users } from "../db/schema.js";
import jwt from "jsonwebtoken";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import { auth, AuthRequest } from "../middleware/auth.js";
import { error } from "console";

const authRouter = Router();

// token for Test123 : 
// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZlMjM3N2MwLWRmMTAtNDQyMC04OTUyLWU4MDkwOTJlYjZhOCIsImlhdCI6MTc2MTkzNDAzNX0.lTVucgaWUdHJ0kocRL5mCcpRxWjj1GMwgQKN-yBZyd8 

interface SignUpBody {
    name: string;
    email: string;
    password: string;
}

interface LogInBody {
    email: string,
    password: string,
}

authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try {
        // get req body
        const {name, email, password} = req.body;
        // check if the user is already exits
        const existingUser = await db.select().from(users).where(eq(users.email, email));
        if (existingUser.length) {
            res.status(400).json({error: "Users with the same email already exits!"});
            return;
        };
        // hash password
        const hashedPassword = await bcryptjs.hash(password, 8);
        // create new user and add to db
        const newUser : NewUser = {
            name,
            email,
            password: hashedPassword
        }
        const [user] = await db.insert(users).values(newUser).returning();
        res.status(200).json(user);
    } catch (e) {
        res.status(500).json({error: e})
    }
})

authRouter.post("/login", async (req: Request<{}, {}, LogInBody>, res: Response) => {
    try {
        // get req body
        const {email, password} = req.body;
        // check if the user is already exits
        const [existingUser] = await db.select().from(users).where(eq(users.email, email));
        if (!existingUser) {
            res.status(400).json({error: "Email does not exits!"});
            return;
        };
        // hash password
        const isMatch = await bcryptjs.compare(password, existingUser.password);
        if (!isMatch) {
            res.status(400).json({error: "Incorrect password!"});
            return;
        }

        const token = jwt.sign({id: existingUser.id}, "passwordKey");

        res.json({token, ...existingUser});
    } catch (e) {
        res.status(500).json({error: e})
    }
})

authRouter.post("/isTokenValid", async (req, res) => {
    try {
        // get the header
        const token = req.header("x-auth-token");
        if (!token) {res.json(false); return;};

        // vertify the token is valid
        const verified = jwt.verify(token, "passwordKey");
        if (!verified) {res.json(false); return;};

        // get user data if token is valid
        const verifiedToken = verified as {id: string};
        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));

        // if no user, return false
        if (!user) {res.json(false); return;};
        
        res.json(true);
    } catch (e) {
        res.status(500).json(false);
    }
})

authRouter.get('/', auth, async (req: AuthRequest, res) => {
    try {
        if (!req.user) {
            res.status(401).json({error: "User not found"});
            return;
        }

        const [user] = await db.select().from(users).where(eq(users.id, req.user));

        res.json({...user, token: req.token});
    } catch (e) {
        res.status(500).json(false);
    }
});

export default authRouter;
