function validate(schema, source = 'query') {
  return (req, res, next) => {
    const { error, value } = schema.validate(req[source], {
      abortEarly: false,
      stripUnknown: true,
      convert: true,
    });

    if (error) {
      return res.status(400).json({
        message: 'Input tidak valid.',
        details: error.details.map((detail) => detail.message),
      });
    }

    req[source] = value;
    next();
  };
}

module.exports = { validate };
