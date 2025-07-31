import * as functions from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import nodemailer from 'nodemailer';
import { defineSecret } from 'firebase-functions/params';

// Initialize Firebase Admin
admin.initializeApp();
const firestore = admin.firestore();

// 🔐 Define secrets (set these using: firebase functions:secrets:set)
const gmailEmail = defineSecret('GMAIL_EMAIL');
const gmailPass = defineSecret('GMAIL_PASSWORD');

export const onUserVerified = functions.onDocumentUpdated(
  {
    document: 'pending_users/{userId}',
    secrets: [gmailEmail, gmailPass], // Include required secrets
  },
  async (event) => {
    // Initialize nodemailer with secret values
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: gmailEmail.value(),
        pass: gmailPass.value(),
      },
    });

    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const userId = event.params.userId;

    if (!before || !after) return;

    // Check if `verified` changed from false to true
    if (before.verified === false && after.verified === true) {
      try {
        const updatedUserData = {
          ...after,
          activated: true,
          verified: true,
          approvedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        // ✅ Move to verified_users collection
        await firestore.collection('verified_users').doc(userId).set(updatedUserData);

        // ❌ Delete from pending_users collection
        await firestore.collection('pending_users').doc(userId).delete();

        console.log(`User ${userId} moved to verified_users and activated.`);

        // 📧 Send confirmation email
        const recipientEmail = after.email;
        const recipientName = after.name || 'User';

        const mailOptions = {
          from: `"ShieldUp Team" <${gmailEmail.value()}>`,
          to: recipientEmail,
          subject: 'Your Account Has Been Approved!',
          text: `Hi ${recipientName}, your account has been verified and activated. You can now log in.`,
          html: `
            <p>Hi <strong>${recipientName}</strong>,</p>
            <p>Your account has been <span style="color:green;">verified</span> and <strong>activated</strong>.</p>
            <p>You may now log in to the app.</p>
            <br>
            <p>Thanks,<br>The ShieldUp Team</p>
          `,
        };

        await transporter.sendMail(mailOptions);
        console.log(`Verification email sent to ${recipientEmail}`);
      } catch (error) {
        console.error('Error during user verification and email sending:', error);
      }
    }
  }
);