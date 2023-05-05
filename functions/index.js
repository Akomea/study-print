const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.checkCourseCompletions = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    try {
      const usersSnapshot = await admin.firestore().collection("Users").get();

      // Use Promise.all() to handle the async operations
      await Promise.all(
        usersSnapshot.docs.map(async (userDoc) => {
          const user = userDoc.data();
          const userId = userDoc.id;

          const courses = user.courses || [];
          const completedCourses = user.completedCourses || [];

          // Use Promise.all() and a for...of loop to handle async operations
          await Promise.all(
            courses.map(async (course) => {
              try {
                const enrollmentDate = course.enrollmentDate.toDate();
                const duration = course.duration;
                const completionDate = new Date(enrollmentDate);

                // Temporary line for testing, change the course duration to 1 minute
                //completionDate.setMinutes(completionDate.getMinutes() + 1);
                completionDate.setDate(completionDate.getDate() + duration * 7);


                if (completionDate <= new Date()) {
                  const courseAlreadyCompleted = completedCourses.some(completedCourse => completedCourse.courseId === course.courseId);

                  const userRef = admin.firestore().collection("Users").doc(userId);
                  const updateData = {
                    courses: admin.firestore.FieldValue.arrayRemove(course),
                  };

                  if (!courseAlreadyCompleted) {
                    updateData.completedCourses = admin.firestore.FieldValue.arrayUnion({
                      courseId: course.courseId,
                      completionDate: admin.firestore.Timestamp.fromDate(completionDate),
                    });
                  }

                  await userRef.update(updateData);

                  console.log(`Course with courseId: ${course.courseId} completed for user: ${userId}`);
                } else {
                  console.log(`Course with courseId: ${course.courseId} not yet completed for user: ${userId}`);
                }

              } catch (error) {
                console.error(`Error processing course with courseId: ${course.courseId} for user: ${userId}`, error);
              }
            })
          );
        })
      );
    } catch (error) {
      console.error("Error processing userDocs:", error);
    }
  });
