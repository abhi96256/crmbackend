const fs = require('fs');
const path = require('path');

const routesDir = path.join(__dirname, 'routes');

// Read all JS files in routes directory
const files = fs.readdirSync(routesDir).filter(file => file.endsWith('.js'));

files.forEach(file => {
  const filePath = path.join(routesDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  
  console.log(`Fixing ${file}...`);
  
  // Replace import statements with require
  content = content.replace(/import express from 'express';/g, "const express = require('express');");
  content = content.replace(/import db from '\.\.\/utils\/database\.js';/g, "const { db } = require('../utils/database.js');");
  content = content.replace(/import \{ body, validationResult \} from 'express-validator';/g, "const { body, validationResult } = require('express-validator');");
  content = content.replace(/import bcrypt from 'bcryptjs';/g, "const bcrypt = require('bcryptjs');");
  content = content.replace(/import jwt from 'jsonwebtoken';/g, "const jwt = require('jsonwebtoken');");
  content = content.replace(/import \{ auth, adminAuth \} from '\.\.\/middleware\/auth\.js';/g, "const { auth, adminAuth } = require('../middleware/auth.js');");
  content = content.replace(/import nodemailer from 'nodemailer';/g, "const nodemailer = require('nodemailer');");
  content = content.replace(/import axios from 'axios';/g, "const axios = require('axios');");
  
  // Replace export default with module.exports
  content = content.replace(/export default router;/g, "module.exports = router;");
  
  // Write back to file
  fs.writeFileSync(filePath, content);
  console.log(`✅ Fixed ${file}`);
});

console.log('\n🎉 All route files fixed!');
