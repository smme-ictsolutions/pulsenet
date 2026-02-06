import {
  onDocumentWritten,
} from "firebase-functions/v2/firestore";
import admin = require("firebase-admin");
import nodemailer from "nodemailer";

admin.initializeApp();

const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: "transnetspotlight@gmail.com",
    pass: "ovjz eyns xpqm dabk",
  },
  tls: {
    rejectUnauthorized: false,
  },
});

export const sendEmail = onDocumentWritten({
  document: "users/vesselpreplan",
}, async (event) => {
  if (event.data?.after) {
    try {
      const data = event.data.after.data();
      const res = data?.url;
      if (data?.url=="") {
        console.log("no url");
        return;
      }
      const mailOptions = {
        from: "transnetspotlight@gmail.com",
        to: "bbcinnovate@transnet.net",
        subject: res, // email subject
        html: `<p style="font-size: 16px;">New preplan entry</p>
            <br />
        `, // email content in HTML
      };
      // returning result
      transporter.sendMail(mailOptions, (erro, info) => {
        if (erro) {
          transporter.close();
          console.log(erro.toString());
          return;
        }
        console.log("email sent", info.response);
        return null;
      });
    } catch (error) {
      console.log("send error", error);
      transporter.close();
      return;
    }
  } else {
    console.log("no data");
    return;
  }
});
