import APIClient from './APIClient';

export default {
  searchCourses(query) {
    return APIClient.client().get(`/api/v2/courses.json?search=${encodeURIComponent(query)}`);
  },
  getCourseTeeBoxes(courseId) {
    return APIClient.client().get(`/api/v2/courses/${courseId}/course_tee_boxes.json`);
  },
};
